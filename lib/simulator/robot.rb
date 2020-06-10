module TAC
  class Simulator
    class Robot
      attr_accessor :position, :angle
      def initialize(width:, depth:)
        @width, @depth = width, depth

        @position = CyberarmEngine::Vector.new
        @angle = 0
      end

      def draw
        Gosu.rotate(@angle, @position.x, @position.y) do
          Gosu.draw_rect(@position.x - @width / 2, @position.y - @depth / 2, @width, @depth, Gosu::Color::GREEN)
        end
      end

      def update
        @angle %= 360.0
      end
    end
  end
end