module TAC
  class Simulator
    class Field
      def initialize(container:, season:, simulation:)
        @container = container
        @season = season
        @simulation = simulation

        @position = CyberarmEngine::Vector.new
        @scale = 1
        @size = 0
        @field_size = 144 # inches [1 pxel = 1 inch]

        @blue = Gosu::Color.new(0xff_004080)
        @red = Gosu::Color.new(0xff_800000)
      end

      def draw
        Gosu.clip_to(@position.x, @position.y, @size, @size) do
          Gosu.translate(@position.x, @position.y) do
            draw_field
            Gosu.scale(@scale) do
              self.send(:"draw_field_#{@season}")

              @simulation.robots.each(&:draw)
              @simulation.robots.each { |robot| robot.queue.first.draw if robot.queue.first }
            end
          end
        end
      end

      def draw_field
        Gosu.draw_rect(0, 0, @field_size * @scale, @field_size * @scale, Gosu::Color::GRAY)
        6.times do |i| # Tile lines across
          next if i == 0
          Gosu.draw_rect((@field_size * @scale) / 6 * i, 0, 1, @field_size * @scale, Gosu::Color::BLACK)
        end
        6.times do |i| # Tile lines down
          next if i == 0
          Gosu.draw_rect(0, (@field_size * @scale) / 6 * i, @field_size * @scale, 1, Gosu::Color::BLACK)
        end
      end

      def draw_field_skystone
        # blue bridge
        Gosu.draw_rect(0, @field_size / 2 - 2, 48, 1, @blue)
        Gosu.draw_rect(0, @field_size / 2 + 1, 48, 1, @blue)

        # mid bridge
        Gosu.draw_rect(@field_size / 2 - 24, @field_size / 2 - 9.25, 48, 18.5, Gosu::Color.new(0xff_222222))
        Gosu.draw_rect(@field_size / 2 - 24, @field_size / 2 - 2, 48, 1, Gosu::Color::YELLOW)
        Gosu.draw_rect(@field_size / 2 - 24, @field_size / 2 + 1, 48, 1, Gosu::Color::YELLOW)

        # blue bridge
        Gosu.draw_rect(@field_size - 48, @field_size / 2 - 2, 48, 1, @red)
        Gosu.draw_rect(@field_size - 48, @field_size / 2 + 1, 48, 1, @red)

        # blue build site
        Gosu.draw_quad(
          24 - 2, 0,      @blue,
          24,     0,      @blue,
          0,      24 - 2, @blue,
          0,      24,     @blue
          )

        # red build site
        Gosu.draw_quad(
          @field_size - (24 - 2), 0,        @red,
          @field_size - (24 - 0), 0,        @red,
          @field_size,            24 - 2,   @red,
          @field_size,            24,       @red
          )

        # blue depot
        Gosu.draw_rect(@field_size - 24, @field_size - 24, 24, 2, @blue)
        Gosu.draw_rect(@field_size - 24, @field_size - 24, 2, 24, @blue)

        # red depot
        Gosu.draw_rect(-1,  @field_size - 24, 24, 2, @red)
        Gosu.draw_rect(22, @field_size - 24, 2, 24, @red)

        # blue foundation
        Gosu.draw_rect(48, 4, 18.5, 34.5, @blue)

        # red foundation
        Gosu.draw_rect(@field_size - (48 + 18.5), 4, 18.5, 34.5, @red)

        # stones
        6.times do |i|
          Gosu.draw_rect(48, @field_size - 8 * i - 8, 4, 8, Gosu::Color::YELLOW)
        end
        6.times do |i|
          Gosu.draw_rect(@field_size - (48 + 4), @field_size - 8 * i - 8, 4, 8, Gosu::Color::YELLOW)
        end
      end

      def update
        @position.x, @position.y = @container.x, @container.y
        @size = @container.width
        @scale = @size.to_f / @field_size
      end
    end
  end
end