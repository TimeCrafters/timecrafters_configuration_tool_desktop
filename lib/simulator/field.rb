module TAC
  class Simulator
    class Field
      attr_reader :scale

      def initialize(container:, season:, simulation:)
        @container = container
        @season = season
        @simulation = simulation

        @position = CyberarmEngine::Vector.new
        @scale = 1
        @size = 0
        @field_size = 144 # inches [1 pixel = 1 inch]
        @z = @container.z + 1

        @blue = Gosu::Color.new(0xff_004080)
        @red = Gosu::Color.new(0xff_800000)
        @soft_orange = Gosu::Color.rgb(255, 175, 0)
      end

      def draw
        Gosu.clip_to(@position.x, @position.y, @size, @size) do
          Gosu.translate(@position.x, @position.y) do
            draw_field
            Gosu.scale(@scale) do
              self.send(:"draw_field_#{@season}")

              @simulation&.robots&.each(&:draw)
              @simulation&.robots&.each { |robot| robot.queue.first.draw if robot.queue.first && @simulation.show_paths }
            end
          end
        end
      end

      def draw_field
        Gosu.draw_rect(0, 0, @field_size * @scale, @field_size * @scale, Gosu::Color::GRAY, @z)
        6.times do |i| # Tile lines across
          next if i == 0
          Gosu.draw_rect((@field_size * @scale) / 6 * i, 0, 1, @field_size * @scale, Gosu::Color::BLACK, @z)
        end
        6.times do |i| # Tile lines down
          next if i == 0
          Gosu.draw_rect(0, (@field_size * @scale) / 6 * i, @field_size * @scale, 1, Gosu::Color::BLACK, @z)
        end
      end

      def draw_field_skystone
        # blue bridge
        Gosu.draw_rect(0, @field_size / 2 - 2, 48, 1, @blue, @z)
        Gosu.draw_rect(0, @field_size / 2 + 1, 48, 1, @blue, @z)

        # mid bridge
        Gosu.draw_rect(@field_size / 2 - 24, @field_size / 2 - 9.25, 48, 18.5, Gosu::Color.new(0xff_222222), @z)
        Gosu.draw_rect(@field_size / 2 - 24, @field_size / 2 - 2, 48, 1, @soft_orange, @z)
        Gosu.draw_rect(@field_size / 2 - 24, @field_size / 2 + 1, 48, 1, @soft_orange, @z)

        # blue bridge
        Gosu.draw_rect(@field_size - 48, @field_size / 2 - 2, 48, 1, @red, @z)
        Gosu.draw_rect(@field_size - 48, @field_size / 2 + 1, 48, 1, @red, @z)

        # blue build site
        Gosu.draw_quad(
          24 - 2, 0,      @blue,
          24,     0,      @blue,
          0,      24 - 2, @blue,
          0,      24,     @blue,
          @z
        )

        # red build site
        Gosu.draw_quad(
          @field_size - (24 - 2), 0,        @red,
          @field_size - (24 - 0), 0,        @red,
          @field_size,            24 - 2,   @red,
          @field_size,            24,       @red,
          @z
        )

        # blue depot
        Gosu.draw_rect(@field_size - 24, @field_size - 24, 24, 2, @blue, @z)
        Gosu.draw_rect(@field_size - 24, @field_size - 24, 2, 24, @blue, @z)

        # red depot
        Gosu.draw_rect(-1,  @field_size - 24, 24, 2, @red, @z)
        Gosu.draw_rect(22, @field_size - 24, 2, 24, @red, @z)

        # blue foundation
        Gosu.draw_rect(48, 4, 18.5, 34.5, @blue, @z)

        # red foundation
        Gosu.draw_rect(@field_size - (48 + 18.5), 4, 18.5, 34.5, @red, @z)

        # stones
        6.times do |i|
          Gosu.draw_rect(48, @field_size - 8 * i - 8, 4, 8, @soft_orange, @z)
        end
        6.times do |i|
          Gosu.draw_rect(@field_size - (48 + 4), @field_size - 8 * i - 8, 4, 8, @soft_orange, @z)
        end
      end

      def draw_field_ultimate_goal
        # middle line
        Gosu.draw_rect(0, @field_size / 2 - 13, @field_size, 2, Gosu::Color::WHITE, @z)

        # phantom center line to indict half field for remote season field
        Gosu.draw_rect(@field_size / 2 - (0.5 + 24), 0, 1, @field_size, 0x88_448844, @z)


        # blue starting lines
        Gosu.draw_rect(24 - 1, @field_size - 24, 2, 24, @blue, @z)
        Gosu.draw_rect(48 - 1, @field_size - 24, 2, 24, @blue, @z)

        # blue wobbly wobs
        Gosu.draw_circle(24, @field_size - 24, 4, 32, @blue, @z)
        Gosu.draw_circle(48, @field_size - 24, 4, 32, @blue, @z)

        # blue starter stack
        Gosu.draw_rect(36 - 1, @field_size - 50, 2, 2, @blue, @z)

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
        Gosu.draw_rect(@field_size - 24 - 1, @field_size - 24, 2, 24, @red, @z)
        Gosu.draw_rect(@field_size - 48 - 1, @field_size - 24, 2, 24, @red, @z)

        # red wobbly wobs
        Gosu.draw_circle(@field_size - 24, @field_size - 24, 4, 32, @red, @z)
        Gosu.draw_circle(@field_size - 48, @field_size - 24, 4, 32, @red, @z)

        # red starter stack
        Gosu.draw_rect(@field_size - 37, @field_size - 50, 2, 2, @red, @z)

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

      def draw_field_freight_frenzy
        # blue ZONE
        Gosu.draw_rect(24, @field_size - 24, 2, 24, @blue, @z)
        Gosu.draw_rect(24, @field_size - 24, 24, 2, @blue, @z)
        Gosu.draw_rect(48 - 2, @field_size - 24, 2, 24, @blue, @z)

        # blue barcode 1
        Gosu.draw_rect(36 - 1, @field_size - 24 - 4, 2, 2, @blue, @z)
        Gosu.draw_rect(36 - 1, @field_size - 36 - 1, 2, 2, @blue, @z)
        Gosu.draw_rect(36 - 1, @field_size - 48 + 2, 2, 2, @blue, @z)

        # blue barcode 2
        Gosu.draw_rect(36 - 1, 48 + 2, 2, 2, @blue, @z)
        Gosu.draw_rect(36 - 1, 60 - 1, 2, 2, @blue, @z)
        Gosu.draw_rect(36 - 1, 72 - 4, 2, 2, @blue, @z)

        # blue wobble goal
        Gosu.draw_circle(48, 84, 9, 32, @blue, @z)

        # blue shared wobble goal
        Gosu.draw_circle(@field_size / 2, 24, 9, 32, @blue, @z)

        # red ZONE
        Gosu.draw_rect(@field_size - 24 - 2, @field_size - 24, 2, 24, @red, @z)
        Gosu.draw_rect(@field_size - 48, @field_size - 24, 24, 2, @red, @z)
        Gosu.draw_rect(@field_size - 48, @field_size - 24, 2, 24, @red, @z)

        # red barcode 1
        Gosu.draw_rect(@field_size - 36 - 1, @field_size - 24 - 4, 2, 2, @red, @z)
        Gosu.draw_rect(@field_size - 36 - 1, @field_size - 36 - 1, 2, 2, @red, @z)
        Gosu.draw_rect(@field_size - 36 - 1, @field_size - 48 + 2, 2, 2, @red, @z)

        # red barcode 2
        Gosu.draw_rect(@field_size - 36 - 1, 48 + 2, 2, 2, @red, @z)
        Gosu.draw_rect(@field_size - 36 - 1, 60 - 1, 2, 2, @red, @z)
        Gosu.draw_rect(@field_size - 36 - 1, 72 - 4, 2, 2, @red, @z)

        # red wobble goal
        Gosu.draw_circle(@field_size - 48, 84, 9, 32, @red, @z)

        # red shared wobble goal
        # Gosu.clip_to(@field_size / 2, 0, 10, 48) do
          Gosu.draw_circle(@field_size / 2, 24, 9, 32, @red, @z)
        # end

        # white corner left
        faint_white = Gosu::Color.rgb(240, 240, 240)

        Gosu.draw_rect(0, 46 - 2, 46, 2, faint_white, @z)
        Gosu.draw_rect(46 - 2, 0, 2, 46, faint_white, @z)
        # white corner right
        Gosu.draw_rect(@field_size - 46, 46 - 2, 46, 2, faint_white, @z)
        Gosu.draw_rect(@field_size - 46, 0, 2, 46, faint_white, @z)

        # cross bars
        bar_gray = Gosu::Color.rgb(50, 50, 50)
        #   MAIN
        Gosu.draw_rect(13.75, 48 - 2, @field_size - 13.75 * 2, 1, bar_gray, @z)
        Gosu.draw_rect(13.75, 48 + 1, @field_size - 13.75 * 2, 1, bar_gray, @z)
        Gosu.draw_rect(13.75, 48 - 2, 1, 4, Gosu::Color::BLACK, @z)
        Gosu.draw_rect(@field_size - 13.75 - 1, 48 - 2, 1, 4, Gosu::Color::BLACK, @z)

        #   BLUE
        Gosu.draw_rect(48 - 2, 13.75, 1, 48 - 13.75 - 2, bar_gray, @z)
        Gosu.draw_rect(48 + 1, 13.75, 1, 48 - 13.75 - 2, bar_gray, @z)
        Gosu.draw_rect(48 - 2, 13.75, 4, 1, Gosu::Color::BLACK, @z)
        Gosu.draw_rect(48 - 2, 48 - 3, 4, 1, Gosu::Color::BLACK, @z)

        #   RED
        Gosu.draw_rect(@field_size - 48 - 2, 13.75, 1, 48 - 13.75 - 2, bar_gray, @z)
        Gosu.draw_rect(@field_size - 48 + 1, 13.75, 1, 48 - 13.75 - 2, bar_gray, @z)
        Gosu.draw_rect(@field_size - 48 - 2, 13.75, 4, 1, Gosu::Color::BLACK, @z)
        Gosu.draw_rect(@field_size - 48 - 2, 48 - 3, 4, 1, Gosu::Color::BLACK, @z)

        # Duck Delivery
        Gosu.draw_circle(2, @field_size - 2, 9, 16, Gosu::Color.rgb(75, 75, 75))
        Gosu.draw_circle(@field_size - 2, @field_size - 2, 9, 16, Gosu::Color.rgb(75, 75, 75))

        7.times do |y|
          7.times do |x|
            if x.even?
              Gosu.draw_rect(x * 3 + 1, y * 3 + 1, 2, 2, @soft_orange, @z)
            else
              Gosu.draw_circle(x * 3 + 2, y * 3 + 2, 1, 16, faint_white, @z)
            end
          end
        end

        7.times do |y|
          7.times do |x|
            if x.even?
              Gosu.draw_rect((@field_size - 4) - x * 3 + 1, y * 3 + 1, 2, 2, @soft_orange, @z)
            else
              Gosu.draw_circle((@field_size - 4) - x * 3 + 2, y * 3 + 2, 1, 16, faint_white, @z)
            end
          end
        end

        Gosu.draw_rect(0, 60 - 1, 2, 2, @soft_orange, @z)
        Gosu.draw_rect(0, 108 - 1, 2, 2, @soft_orange, @z)
        Gosu.draw_rect(@field_size - 2, 60 - 1, 2, 2, @soft_orange, @z)
        Gosu.draw_rect(@field_size - 2, 108 - 1, 2, 2, @soft_orange, @z)
      end

      def draw_field_power_play
        # pole junctions (Drawn before ground junctions to be lazy- ground junctions will cover non-existant poles)
        5.times do |y|
          5.times do |x|
            Gosu.draw_circle(24 + (x * 24), 24 + (y * 24), 0.5, 16, @soft_orange, @z)
          end
        end

        # ground junction
        3.times do |y|
          3.times do |x|
            Gosu.draw_circle(24 + (x * 48), 24 + (y * 48), 3, 16, Gosu::Color::BLACK, @z)
          end
        end

        # Field cones
        2.times do |y|
          2.times do |x|
            Gosu.draw_circle(36 + (x * 72), 36 + (y * 72), 2, 16, x.zero? ? @blue : @red, @z)
          end
        end

        # alliance LINEs
        2.times do |y|
          2.times do |x|
            Gosu.draw_rect(59 + (x * 24), y * (144 - 23.5), 2, 23.5, x.zero? ? @blue : @red, @z)
          end
        end

        # alliance LINE cones
        2.times do |y|
          2.times do |x|
            Gosu.draw_circle(60 + (x * 24), y * (144 - 4) + 2, 2, 16, x.zero? ? @blue : @red, @z)
          end
        end

        # Corner TAPE
        4.times do |i|
          Gosu.rotate(i * 90.0, 72, 72) do
            Gosu.draw_quad(
              24 - 2, 0,      i.even? ? @red : @blue,
              24,     0,      i.even? ? @red : @blue,
              0,      24 - 2, i.even? ? @red : @blue,
              0,      24,     i.even? ? @red : @blue,
              @z
            )
          end
        end

        # Triangle TAPE
        2.times do |i|
          Gosu.rotate(i * 180.0, 72, 72) do
            Gosu.draw_quad(
              0,    72 - 10.5, i.odd? ? @red : @blue,
              10.5, 72,        i.odd? ? @red : @blue,
              8.5,  72,        i.odd? ? @red : @blue,
              0,    72 - 8.5,  i.odd? ? @red : @blue,
              @z
            )

            Gosu.draw_quad(
              0,    72 + 10.5, i.odd? ? @red : @blue,
              10.5, 72,        i.odd? ? @red : @blue,
              8.5,  72,        i.odd? ? @red : @blue,
              0,    72 + 8.5,  i.odd? ? @red : @blue,
              @z
            )
          end
        end
      end

      def draw_field_centerstage

      end

      def draw_tile_box(color)
        Gosu.draw_rect(0,  0, 24, 2, color, @z)
        Gosu.draw_rect(22, 2, 2, 22, color, @z)
        Gosu.draw_rect(0, 22, 22, 2, color, @z)
        Gosu.draw_rect(0,  2, 2, 22, color, @z)
      end

      def update
        @position.x = @container.x
        @position.y = @container.y
        @size = [@container.width, @container.height].min
        @scale = @size.to_f / @field_size
      end
    end
  end
end