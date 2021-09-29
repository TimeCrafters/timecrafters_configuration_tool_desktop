require "securerandom"

module TAC
  class PracticeGameClock
    class Randomizer < CyberarmEngine::GameState
      def setup
        @roll = SecureRandom.random_number(1..6)

        @position = CyberarmEngine::Vector.new

        @dimple_color = 0xff_008000
        @dimple_res = 36

        @size = [window.width, window.height].min / 2.0

        @rings = []

        case @roll
        when 1, 4
        when 2, 5
          @rings << Ring.new(position: CyberarmEngine::Vector.new(-@size, window.height * 0.9), speed: 512)
        when 3, 6
          @rings << Ring.new(position: CyberarmEngine::Vector.new(-@size, window.height * 0.9), speed: 512)
          @rings << Ring.new(position: CyberarmEngine::Vector.new(-@size * 1.25, window.height * 0.8), speed: 512)
          @rings << Ring.new(position: CyberarmEngine::Vector.new(-@size * 1.50, window.height * 0.7), speed: 512)
          @rings << Ring.new(position: CyberarmEngine::Vector.new(-@size * 1.75, window.height * 0.6), speed: 512)
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

        @rings.each { |r| r.draw(@size) }
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

      def dimple(size)
        size / 9.0
      end

      def update
        window.previous_state&.update_non_gui

        @rings.each { |r| r.update(window, @size) }

        @size = [window.width, window.height].min / 2.0
      end

      def button_down(id)
        case id
        when Gosu::MS_LEFT, Gosu::KB_ESCAPE, Gosu::KB_SPACE
          pop_state
        end
      end

      class Ring
        def initialize(position:, speed: 1)
          @position = position
          @speed = speed
          @color = 0xff_ffaa00
        end

        def draw(size)
          Gosu.translate(@position.x, @position.y) do
            Gosu.draw_rect(0, 0, size, size * 0.10, @color)
          end
        end

        def update(window, size)
          center = window.width * 0.5 - size * 0.5

          @position.x += @speed * window.dt
          @position.x = center if @position.x > center
        end
      end
    end
  end
end
