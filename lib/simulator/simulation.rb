module TAC
  class Simulator
    class Simulation
      attr_reader :robot
      def initialize(source_code:, field_container:)
        @source_code = source_code
        @field_container = field_container

        @robot = Simulator::Robot.new(width: 18, depth: 18)
        @field = Field.new(robot: @robot, season: :skystone, container: @field_container)
        @queue = []

        @unit = :ticks
        @ticks_per_revolution = 240
        @gear_ratio = 1

        @last_milliseconds = Gosu.milliseconds
      end

      def __start
        self.instance_eval(@source_code)
      end

      def __draw
        @field.draw
      end

      def __update
        @field.update
        @robot.update

        if state = @queue.first
          state.update((Gosu.milliseconds - @last_milliseconds) / 1000.0)

          @queue.delete(state) if state.complete?
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

      def forward(distance, power)
        @queue << Move.new(simulation: self, distance: distance, power: power)
      end

      def backward(distance, power)
        @queue << Move.new(simulation: self, distance: -distance, power: power)
      end

      def turn(relative_angle, power)
        @queue << Turn.new(simulation: self, relative_angle: relative_angle, power: power)
      end

      def __speed
        @ticks_per_revolution * @gear_ratio
      end

      class State
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

          @starting_position = @robot.position.clone
          @goal = @starting_position.clone
          @goal.x += @distance * Math.cos(@robot.angle.gosu_to_radians)
          @goal.y += @distance * Math.sin(@robot.angle.gosu_to_radians)

          @complete = false
          @allowable_error = 3.0
        end

        def update(dt)
          target = @starting_position + @goal
          speed = (@distance > 0 ? @power * dt : -@power * dt) * @simulation.__speed

          # TODO: Fix not stopping if travelling at an angle
          if @robot.position.distance(target) <= @allowable_error
            @complete = true
          else
            @robot.position.x += Math.cos(@robot.angle.gosu_to_radians) * speed
            @robot.position.y += Math.sin(@robot.angle.gosu_to_radians) * speed
          end
        end
      end

      class Turn < State
        def initialize(simulation:, relative_angle:, power:)
          @simulation = simulation
          @robot = @simulation.robot
          @relative_angle = relative_angle
          @power = power

          @starting_angle = @robot.angle
          @last_angle = @starting_angle
          @complete = false
          @allowable_error = 3.0
        end

        def update(dt)
          target_angle = (@starting_angle + @relative_angle) % 360.0

          if @robot.angle.between?(target_angle - @allowable_error, target_angle + @allowable_error)
            @complete = true
          elsif (@robot.angle - @last_angle).between?(target_angle - @allowable_error, target_angle + @allowable_error)
            @complete = true
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