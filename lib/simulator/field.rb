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
        # Corner TAPE
        2.times do |i|
          Gosu.rotate((i + 2) * 90.0, 72, 72) do
            Gosu.draw_quad(
              24 - 2, 0,      i.odd? ? @red : @blue,
              24,     0,      i.odd? ? @red : @blue,
              0,      24 - 2, i.odd? ? @red : @blue,
              0,      24,     i.odd? ? @red : @blue,
              @z
            )
          end
        end

        # Backstage TAPE
        # BLUE
        Gosu.draw_rect(0, 22, 58.5, 2, @blue, @z)
        Gosu.draw_quad(
          72 - 2, 0,      @blue,
          72,     0,      @blue,
          58.5 - 2,  24,  @blue,
          58.5,      24,  @blue,
          @z
        )
        # RED
        Gosu.draw_rect(@field_size, 22, -58.5, 2, @red, @z)
        Gosu.draw_quad(
          @field_size - (72 - 2), 0,      @red,
          @field_size - 72,     0,      @red,
          @field_size - (58.5 - 2),  24,  @red,
          @field_size - 58.5,      24,  @red,
          @z
        )

        # Backstage BACKDROP
        Gosu.draw_rect(24, 0, 24, 11.25, 0xff_252525, @z)
        Gosu.draw_rect(@field_size - 48, 0, 24, 11.25, 0xff_252525, @z)

        # Pixel TAPE
        7.times do |i|
          next if i == 3 # skip 4th iteration; empty slot

          # TAPE
          Gosu.draw_rect(24 + 11.5 + (12 * i), @field_size - 6, 1, 6, 0xff_dddddd, @z)
          # Pixel
          Gosu.rotate(30, 24 + 12 + (12 * i), @field_size - 1.75) do
            Gosu.draw_circle(24 + 12 + (12 * i), @field_size - 1.75, 2.25, 6, 0xff_ffffff, @z)
          end
        end

        # Spike marks TAPE
        # BLUE
        2.times do |r|
          2.times do |i|
            Gosu.rotate(r * 180, @field_size / 2, @field_size / 2 + 12) do
              c = r.even? ? @blue : @red
              Gosu.translate(0, i * 48) do
                Gosu.draw_rect(35.5, @field_size / 2 - 1.5, 12, 1, c, @z)
                Gosu.draw_rect(47.5 - 1, @field_size / 2 - 18, 1, 12, c, @z)
                Gosu.draw_rect(35.5, @field_size / 2 - 23.5, 12, 1, c, @z)
                # --- mark
                Gosu.draw_rect(35.5 + 6, @field_size / 2 - 1.5, 0.125, 1, 0xff_000000, @z)
                Gosu.draw_rect(47.5 - 1, @field_size / 2 - 18 + 6, 1, 0.125, 0xff_000000, @z)
                Gosu.draw_rect(35.5 + 6, @field_size / 2 - 23.5, 0.125, 1, 0xff_000000, @z)
              end
            end
          end
        end

        # Trusses
        Gosu.draw_rect(0, @field_size / 2 - 2, 2, 28, 0xff_656565, @z)
        Gosu.draw_rect(23, @field_size / 2 - 2, 2, 28, 0xff_656565, @z)
        Gosu.draw_rect(47, @field_size / 2 - 2, 2, 28, 0xff_656565, @z)
        Gosu.draw_rect(@field_size / 2 + 24 + -1, @field_size / 2 - 2, 2, 28, 0xff_656565, @z)
        Gosu.draw_rect(@field_size / 2 + 24 + 23, @field_size / 2 - 2, 2, 28, 0xff_656565, @z)
        Gosu.draw_rect(@field_size / 2 + 24 + 46, @field_size / 2 - 2, 2, 28, 0xff_656565, @z)

        # Crossbeams
        # BLUE
        Gosu.draw_rect(0, @field_size / 2 + 12 + 2, 26, 2, @blue, @z)
        Gosu.draw_rect(24, @field_size / 2 + 12 - 1, 24, 2, @blue, @z)
        # YELLOW
        # --- Blue
        Gosu.draw_rect(0, @field_size / 2 + 2, 25, 1, @soft_orange, @z)
        Gosu.draw_rect(23, @field_size / 2 + 21, 26, 1, @soft_orange, @z)
        # --- Middle
        Gosu.draw_rect(24 + 24, @field_size / 2 + 2, 48, 1, @soft_orange, @z)
        Gosu.draw_rect(24 + 24, @field_size / 2 + 12 - 0.5, 48, 1, @soft_orange, @z)
        Gosu.draw_rect(24 + 24, @field_size / 2 + 12 - 0.5, 48, 1, @soft_orange, @z)
        # --- --- parallel beams
        Gosu.draw_rect(24 + 28, @field_size / 2 + 2, 1, 10, @soft_orange, @z)
        Gosu.draw_rect(@field_size / 2, @field_size / 2 + 2, 1, 10, @soft_orange, @z)
        Gosu.draw_rect(24 + 72 - 4, @field_size / 2 + 2, 1, 10, @soft_orange, @z)
        # --- Red
        Gosu.draw_rect(47 + 72, @field_size / 2 + 2, 25, 1, @soft_orange, @z)
        Gosu.draw_rect(23 + 72, @field_size / 2 + 21, 26, 1, @soft_orange, @z)
        # RED
        Gosu.draw_rect(24 + 72, @field_size / 2 + 12 - 1, 24, 2, @red, @z)
        Gosu.draw_rect(46 + 72, @field_size / 2 + 12 + 2, 26, 2, @red, @z)

      end

      #############################
      ### --- Into the Deep --- ###
      #############################
      def draw_field_into_the_deep
        # Observation and net zones
        2.times do |i|
          Gosu.rotate(i * 180.0, 72, 72) do
            Gosu.draw_quad(
              24 - 2, 0,      i.odd? ? @red : @blue,
              24,     0,      i.odd? ? @red : @blue,
              0,      24 - 2, i.odd? ? @red : @blue,
              0,      24,     i.odd? ? @red : @blue,
              @z
            )

            Gosu.draw_rect(
              12, 144 - 24,
              2,  24,
              i.odd? ? @red : @blue,
              @z
            )

            Gosu.draw_quad(
              12,     144 - 24, i.odd? ? @red : @blue,
              14,     144 - 24, i.odd? ? @red : @blue,
              0,      144 - 36, i.odd? ? @red : @blue,
              0,      144 - 38, i.odd? ? @red : @blue,
              @z
            )
          end
        end

        faint_white = Gosu::Color.rgb(240, 240, 240)

        # spike marks, white
        3.times do |i|
          Gosu.draw_rect(
            48 - 3.5, 22 - i * 10,
            3.5, 2,
            faint_white,
            @z
          )
        end
        #spike marks, red
        3.times do |i|
          Gosu.draw_rect(
            (144 - 48), 22 - i * 10,
            3.5, 2,
            @red,
            @z
          )
        end
        # spike marks, blue
        3.times do |i|
          Gosu.draw_rect(
            48 - 3.5, 144 - 24 + i * 10,
            3.5, 2,
            @blue,
            @z
          )
        end
        # spike marks, yellow
        3.times do |i|
          Gosu.draw_rect(
            (144 - 48), 144 - 24 + i * 10,
            3.5, 2,
            faint_white,
            @z
          )
        end

        # Accent Zone Triangle TAPE
        2.times do |i|
          Gosu.rotate(i * 180.0, 72, 72) do
            Gosu.draw_quad(
              48,      48, faint_white,
              72, 48 - 10, faint_white,
              72, 49 - 10, faint_white,
              50,      48, faint_white,
              @z
            )

            Gosu.draw_quad(
              96,      48, faint_white,
              72, 48 - 10, faint_white,
              72, 49 - 10, faint_white,
              94,      48, faint_white,
              @z
            )
          end
        end

        # submersible
        bar_gray = 0xff_656565 #Gosu::Color.rgb(50, 50, 50)

        2.times do |i|
          # left and right edges of submersible
          Gosu.draw_rect(
            72 - 24 + i * 46, 72 - 24,
            2, 48,
            bar_gray,
            @z
          )

          # top and bottom edges of submersible
          Gosu.draw_rect(
            72 - 24, 72 - 15 + i * 28,
            48, 2,
            bar_gray,
            @z
          )

          # alliance rungs of submersible
          Gosu.draw_rect(
            72 - 24 + i * 46, 72 - 13,
            2, 26,
            i.even? ? @blue : @red,
            @z
          )
        end

        # alliance bar bars
        2.times do |i|
          3.times do |x|
            Gosu.draw_rect(
              72 - 21.5 + x * 21, 72 - 15 + i * 28,
              1, 2,
              i.even? ? @blue : @red,
              @z
            )
          end
        end
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