require "securerandom"

module TAC
  class PracticeGameClock
    class Randomizer < CyberarmEngine::GameState
      def setup
        @roll = SecureRandom.random_number(1..6)

        @dimple_color = 0xff_008000
        @dimple_res = 36

        @size = [window.width, window.height].min / 2.0

        @ducks = []

        case @roll
        when 1, 4
          # Blue: Right
          # Red: Left

          @ducks << Ducky.new(window: window, alliance: :blue, slot: 3, speed: 512, die_size: @size)
          @ducks << Ducky.new(window: window, alliance: :red, slot: 1, speed: 512, die_size: @size)
        when 2, 5
          #Blue and Red: Center

          @ducks << Ducky.new(window: window, alliance: :blue, slot: 2, speed: 512, die_size: @size)
          @ducks << Ducky.new(window: window, alliance: :red, slot: 2, speed: 512, die_size: @size)
        when 3, 6
          # Blue: Left
          # Red: Right

          @ducks << Ducky.new(window: window, alliance: :blue, slot: 1, speed: 512, die_size: @size)
          @ducks << Ducky.new(window: window, alliance: :red, slot: 3, speed: 512, die_size: @size)
        end
      end

      def draw
        window.previous_state.draw

        Gosu.flush

        fill(0xdd_202020)

        Gosu.translate(window.width * 0.5 - @size * 0.5, 24) do
          Gosu.draw_rect(0, 0, @size, @size, Gosu::Color::BLACK)
          Gosu.draw_rect(12, 12, @size - 24, @size - 24, Gosu::Color::GRAY)

          self.send(:"dice_#{@roll}", @size)
        end

        @ducks.each { |o| o.draw(@size) }
      end

      def dimple(size)
        size / 9.0
      end

      def update
        window.previous_state&.update_non_gui

        @ducks.each { |o| o.update(@size) }

        @size = [window.width, window.height].min / 2.0
      end

      def button_down(id)
        case id
        when Gosu::MS_LEFT, Gosu::KB_ESCAPE, Gosu::KB_SPACE
          pop_state
        end
      end

      def dice_1(size)
        Gosu.draw_circle(size / 2, size / 2, dimple(size), @dimple_res, @dimple_color)
      end

      def dice_2(size)
        Gosu.draw_circle(size * 0.25, size * 0.25, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.75, size * 0.75, dimple(size), @dimple_res, @dimple_color)
      end

      def dice_3(size)
        Gosu.draw_circle(size * 0.25, size * 0.25, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.50, size * 0.50, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.75, size * 0.75, dimple(size), @dimple_res, @dimple_color)
      end

      def dice_4(size)
        Gosu.draw_circle(size * 0.25, size * 0.25, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.75, size * 0.25, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.25, size * 0.75, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.75, size * 0.75, dimple(size), @dimple_res, @dimple_color)
      end

      def dice_5(size)
        Gosu.draw_circle(size * 0.50, size * 0.50, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.25, size * 0.25, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.75, size * 0.25, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.25, size * 0.75, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.75, size * 0.75, dimple(size), @dimple_res, @dimple_color)
      end

      def dice_6(size)
        Gosu.draw_circle(size * 0.25, size * 0.20, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.75, size * 0.20, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.25, size * 0.50, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.75, size * 0.50, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.25, size * 0.80, dimple(size), @dimple_res, @dimple_color)
        Gosu.draw_circle(size * 0.75, size * 0.80, dimple(size), @dimple_res, @dimple_color)
      end

      class Ducky
        SIZE = 0.20
        HALF_SIZE = SIZE * 0.5

        def initialize(window:, alliance:, slot:, speed:, die_size:)
          @window = window
          @alliance = alliance
          @slot = slot
          @speed = speed

          @image = @window.get_image("#{ROOT_PATH}/media/openclipart_ducky.png")
          @debug_text = Gosu::Font.new(28)

          if @alliance == :blue
            @position = CyberarmEngine::Vector.new(@window.width, die_size)
          else
            @position = CyberarmEngine::Vector.new(-die_size, die_size + die_size * 0.40)
          end
        end

        def draw(size)
          Gosu.translate(@position.x, @position.y) do
            Gosu.draw_rect(0, size * SIZE, size * SIZE, size * SIZE, alliance_color)
            Gosu.draw_rect(size * 0.5 - size * HALF_SIZE, size * SIZE, size * SIZE, size * SIZE, alliance_color)
            Gosu.draw_rect(size * (1.0 - SIZE), size * SIZE, size * SIZE, size * SIZE, alliance_color)

            duck_scale = (size * (SIZE + HALF_SIZE)) / @image.width
            duck_scale_x = @alliance == :blue ? -duck_scale : duck_scale
            @image.draw_rot(slot_position(size), size * SIZE + float_y(size), 1, 0, 0.5, 0.5, duck_scale_x, duck_scale)
          end
        end

        def update(size)
          center = @window.width * 0.5 - size * 0.5

          if @position.x > center
            @position.x -= @speed * @window.dt
            @position.x = center if @position.x < center
          elsif @position.x < center
            @position.x += @speed * @window.dt
            @position.x = center if @position.x > center
          end
        end

        def alliance_color
          @alliance == :blue ? 0xff_000080 : 0xff_800000
        end

        def slot_position(size)
          case @slot
          when 1
            size * HALF_SIZE
          when 2
            size * 0.5
          when 3
            size * (1.0 - HALF_SIZE)
          else
            raise "Slot value of: #{@slot.inspect} is invalid!"
          end
        end

        def float_y(size)
          Math.sin(Gosu.milliseconds / 100.0) * (size * 0.01)
        end
      end
    end
  end
end
