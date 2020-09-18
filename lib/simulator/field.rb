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
        @field_size = 144 # inches [1 pixel = 1 inch]

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
              @simulation.robots.each { |robot| robot.queue.first.draw if robot.queue.first && @simulation.show_paths }
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

      def draw_field_ultimate_goal
        # middle line
        Gosu.draw_rect(0, @field_size / 2 - 13, @field_size, 2, Gosu::Color::WHITE)

        # phantom center line to indict half field for remote season field
        Gosu.draw_rect(@field_size / 2 - 0.5, 0, 1, @field_size, 0x88_448844)


        # blue starting lines
        Gosu.draw_rect(24 - 1, @field_size - 24, 2, 24, @blue)
        Gosu.draw_rect(48 - 1, @field_size - 24, 2, 24, @blue)

        # blue wobbly wobs
        Gosu.draw_circle(24, @field_size - 24, 4, 32, @blue)
        Gosu.draw_circle(48, @field_size - 24, 4, 32, @blue)

        # blue starter stack
        Gosu.draw_rect(36 - 1, @field_size - 50, 2, 2, @blue)

        # blue target zones
        # A
        draw_tile_box(@blue)

        # B
        Gosu.translate(24, 24) do
          draw_tile_box(@blue)
        end

        # C
        Gosu.translate(0, 48) do
          draw_tile_box(@blue)
        end

        # red starting lines
        Gosu.draw_rect(@field_size - 24 - 1, @field_size - 24, 2, 24, @red)
        Gosu.draw_rect(@field_size - 48 - 1, @field_size - 24, 2, 24, @red)

        # red wobbly wobs
        Gosu.draw_circle(@field_size - 24, @field_size - 24, 4, 32, @red)
        Gosu.draw_circle(@field_size - 48, @field_size - 24, 4, 32, @red)

        # red starter stack
        Gosu.draw_rect(@field_size - 37, @field_size - 50, 2, 2, @red)

        # red target zones
        # A
        Gosu.translate(@field_size - 24, 0) do
          draw_tile_box(@red)
        end

        # B
        Gosu.translate(@field_size - 48, 24) do
          draw_tile_box(@red)
        end

        # C
        Gosu.translate(@field_size - 24, 48) do
          draw_tile_box(@red)
        end
      end

      def draw_tile_box(color)
        Gosu.draw_rect(0,  0, 24, 2, color)
        Gosu.draw_rect(22, 2, 2, 22, color)
        Gosu.draw_rect(0, 22, 22, 2, color)
        Gosu.draw_rect(0,  2, 2, 22, color)
      end

      def update
        @position.x, @position.y = @container.x, @container.y
        @size = @container.width
        @scale = @size.to_f / @field_size
      end
    end
  end
end