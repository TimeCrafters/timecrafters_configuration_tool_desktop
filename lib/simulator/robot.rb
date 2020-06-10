module TAC
  class Simulator
    class Robot
      attr_accessor :position, :angle
      attr_reader :width, :depth
      def initialize(width:, depth:)
        @width, @depth = width, depth

        @position = CyberarmEngine::Vector.new
        @angle = 0
      end

      def draw
        Gosu.translate(@width / 2, @depth / 2) do
          Gosu.rotate(@angle, @position.x, @position.y) do
            Gosu.draw_rect(@position.x - @width / 2, @position.y - @depth / 2, @width, @depth, Gosu::Color::BLACK)
            Gosu.draw_rect(@position.x - @width / 2 + 1, @position.y - @depth / 2 + 1, @width - 2, @depth - 2, Gosu::Color.new(0xff_808022))
            Gosu.draw_arc(@position.x, @position.y, 6, 1.0, 32, 2, TAC::Palette::TIMECRAFTERS_PRIMARY)
            Gosu.draw_circle(@position.x, @position.y - @depth * 0.25, 2, 3, TAC::Palette::TIMECRAFTERS_TERTIARY)
          end
        end
      end

      def update
        @angle %= 360.0
      end
    end
  end
end