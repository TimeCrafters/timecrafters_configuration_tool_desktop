module TAC
  class Simulator
    class Simulation
      attr_reader :robot
      def initialize(source_code:, field_container:)
        @source_code = source_code
        @field_container = field_container

        @robot = Simulator::Robot.new(width: 18, depth: 18)
        @field = Field.new(simulation: self, robot: @robot, season: :skystone, container: @field_container)
        @queue = []

        @unit = :ticks
        @ticks_per_revolution = 240
        @gear_ratio = 1

        @last_milliseconds = Gosu.milliseconds
      end

      def __start
        self.instance_eval(@source_code)
        @queue.first.start unless @queue.empty?
      end

      def __queue
        @queue
      end

      def __draw
        @field.draw
      end

      def __update
        @field.update
        @robot.update

        if state = @queue.first
          state.update((Gosu.milliseconds - @last_milliseconds) / 1000.0)

          if state.complete?
            @queue.delete(state)
            @queue.first.start unless @queue.empty?
          end
        end

        @last_milliseconds = Gosu.milliseconds
      end

      def create_robot(width:, height:)
        @robot = Simulator::Robot.new(width: width, height: height)
      end

      def set_unit(unit, units_per_revolution = unit)
        case unit
        when :ticks, :inches, :centimeters
          @unit = unit
        else
          raise "Unsupported unit '#{unit.inspect}' exected :ticks, :inches or :centimeters"
        end

        @units_per_revolution = units_per_revolution
      end

      def set_gear_ratio(from, to)
        @gear_ratio = Float(from) / Float(to)
      end

      def set_ticks_per_revolution(ticks)
        @ticks_per_revolution = Integer(ticks)
      end

      def forward(distance, power = 0.5)
        @queue << Move.new(simulation: self, distance: distance, power: power)
      end

      def backward(distance, power = 1.0)
        @queue << Move.new(simulation: self, distance: -distance, power: power)
      end

      def turn(relative_angle, power = 1.0)
        @queue << Turn.new(simulation: self, relative_angle: relative_angle, power: power)
      end

      def __speed
        @ticks_per_revolution / @gear_ratio
      end

      class State
        def start
        end

        def draw
        end

        def update(dt)
        end

        def complete?
          @complete
        end
      end

      class Move < State
        def initialize(simulation:, distance:, power:)
          @simulation = simulation
          @robot = @simulation.robot
          @distance = distance
          @power = power
        end

        def start
          @starting_position = @robot.position.clone
          @goal = @starting_position.clone
          @goal.x += Math.cos(@robot.angle.gosu_to_radians) * @distance
          @goal.y += Math.sin(@robot.angle.gosu_to_radians) * @distance

          @complete = false
          @allowable_error = 3.0
        end

        def draw
          Gosu.draw_line(@robot.position.x, @robot.position.y, Gosu::Color::GREEN, @goal.x, @goal.y, Gosu::Color::GREEN)
          Gosu.draw_rect(@goal.x, @goal.y, 16, 16, Gosu::Color::RED)
        end

        def update(dt)
          speed = (@distance > 0 ? @power * dt : -@power * dt) * @simulation.__speed

          if @robot.position.distance(@goal) <= @allowable_error
            @complete = true
            @robot.position = @goal
          else
            if speed > 0
              @robot.position -= (@robot.position - @goal).normalized * speed
            else
              @robot.position += (@robot.position - @goal).normalized * speed
            end
          end
        end
      end

      class Turn < State
        def initialize(simulation:, relative_angle:, power:)
          @simulation = simulation
          @robot = @simulation.robot
          @relative_angle = relative_angle
          @power = power
        end

        def start
          @starting_angle = @robot.angle
          @last_angle = @starting_angle
          @complete = false
          @allowable_error = 3.0
        end

        def update(dt)
          target_angle = (@starting_angle + @relative_angle) % 360.0

          if @robot.angle.between?(target_angle - @allowable_error, target_angle + @allowable_error)
            @complete = true
            @robot.angle = target_angle
          elsif (@robot.angle - @last_angle).between?(target_angle - @allowable_error, target_angle + @allowable_error)
            @complete = true
            @robot.angle = target_angle
          elsif target_angle > @starting_angle
            @robot.angle += @power * dt * @simulation.__speed
          elsif target_angle < @starting_angle
            @robot.angle -= @power * dt * @simulation.__speed
          end

          @last_angle = @robot.angle
        end
      end
    end
  end
end