module TAC
  class Simulator
    class Field
      def initialize(container:, season:, robot:)
        @container = container
        @season = season
        @robot = robot

        @position = CyberarmEngine::Vector.new
        @scale = CyberarmEngine::Vector.new(1, 1)
        @size = 0
      end

      def draw
        Gosu.clip_to(@position.x, @position.y, @size, @size) do
          Gosu.draw_rect(@position.x, @position.y, @size, @size, Gosu::Color::GRAY)
          # Gosu.scale(@scale.x, @scale.y) do
            Gosu.translate(@position.x, @position.y) do
              @robot.draw
            end
          # end
        end
      end

      def update
        @position.x, @position.y = @container.x, @container.y
        @size = @container.width
      end
    end
  end
end