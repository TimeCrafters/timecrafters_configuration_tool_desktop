module TAC
  class Simulator
    class Robot
      attr_accessor :position, :angle
      attr_reader :alliance, :width, :depth
      def initialize(alliance:, width:, depth:)
        @alliance = alliance
        @width, @depth = width, depth

        @position = CyberarmEngine::Vector.new
        @angle = 0

        @queue = []

        @unit = :ticks
        @ticks_per_revolution = 240
        @gear_ratio = 1
      end

      def draw
        Gosu.translate(@width / 2, @depth / 2) do
          Gosu.rotate(@angle, @position.x, @position.y) do
            Gosu.draw_rect(@position.x - @width / 2, @position.y - @depth / 2, @width, @depth, Gosu::Color::BLACK)
            Gosu.draw_rect(@position.x - @width / 2 + 1, @position.y - @depth / 2 + 1, @width - 2, @depth - 2, Gosu::Color.new(0xff_808022))

            if @alliance == :blue
              Gosu.draw_arc(@position.x, @position.y, 6, 1.0, 32, 2, TAC::Palette::BLUE_ALLIANCE)
            elsif @alliance == :red
              Gosu.draw_arc(@position.x, @position.y, 6, 1.0, 32, 2, TAC::Palette::RED_ALLIANCE)
            else
              Gosu.draw_arc(@position.x, @position.y, 6, 1.0, 32, 2, @alliance)
            end
            Gosu.draw_circle(@position.x, @position.y - @depth * 0.25, 2, 3, TAC::Palette::TIMECRAFTERS_TERTIARY)
          end
        end
      end

      def update(dt)
        @angle %= 360.0

        if state = @queue.first
          state.update(dt)

          if state.complete?
            @queue.delete(state)
            @queue.first.start unless @queue.empty?
          end
        end
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
        @queue << Move.new(robot: self, distance: distance, power: power)
      end

      def backward(distance, power = 1.0)
        @queue << Move.new(robot: self, distance: -distance, power: power)
      end

      def turn(relative_angle, power = 1.0)
        @queue << Turn.new(robot: self, relative_angle: relative_angle, power: power)
      end

      def speed
        @ticks_per_revolution / @gear_ratio
      end

      def queue
        @queue
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
        def initialize(robot:, distance:, power:)
          @robot = robot
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
          Gosu.draw_line(@robot.position.x + @robot.width / 2, @robot.position.y + @robot.depth / 2, Gosu::Color::GREEN, @goal.x + @robot.width / 2, @goal.y + @robot.depth / 2, Gosu::Color::GREEN)
          Gosu.draw_rect(@goal.x + (@robot.width / 2 - 2), @goal.y + (@robot.depth / 2 - 2), 4, 4, Gosu::Color::RED)
        end

        def update(dt)
          speed = (@distance > 0 ? @power * dt : -@power * dt) * @robot.speed

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
        def initialize(robot:, relative_angle:, power:)
          @robot = robot
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
            @robot.angle += @power * dt * @robot.speed
          elsif target_angle < @starting_angle
            @robot.angle -= @power * dt * @robot.speed
          end

          @last_angle = @robot.angle
        end
      end
    end
  end
end