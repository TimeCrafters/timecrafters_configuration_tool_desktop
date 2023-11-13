module TAC
  class Pages
    class FieldPlanner < Page
      def setup
        header_bar("Field Planner")

        menu_bar.clear do
          flow(width: 1.0, height: 1.0) do
            button "Inches", text_size: THEME_HEADING_TEXT_SIZE do
              @unit = :inches
              refresh_panel
            end

            button "Feet", text_size: THEME_HEADING_TEXT_SIZE do
              @unit = :feet
              refresh_panel
            end

            button "Millimeters", text_size: THEME_HEADING_TEXT_SIZE do
              @unit = :millimeters
              refresh_panel
            end

            button "Centimeters", text_size: THEME_HEADING_TEXT_SIZE do
              @unit = :centimeters
              refresh_panel
            end

            button "Meters", text_size: THEME_HEADING_TEXT_SIZE do
              @unit = :meters
              refresh_panel
            end

            button "Reset", text_size: THEME_HEADING_TEXT_SIZE, **THEME_DANGER_BUTTON do
              @nodes.clear
              measure_path

              refresh_panel
            end

            list_box items: ["CENTERSTAGE", "Power Play", "Freight Frenzy", "Ultimate Goal", "Skystone"], width: 200, height: 1.0 do |item|
              season = item.downcase.gsub(" ", "_").to_sym
              @field = TAC::Simulator::Field.new(container: @field_container, season: season, simulation: nil)
            end
          end
        end

        status_bar.clear do
          flow(width: 1.0, height: 1.0) do
            tagline "Nodes:"
            @nodes_count_label = tagline "0"

            tagline "Total Distance:", margin_left: 20
            @total_distance_label = tagline "0"

            @units_label = tagline "Inches"
          end
        end

        body.clear do
          flow(width: 1.0, height: 1.0) do
            @field_container = stack width: 0.5, height: 1.0 do
              background 0xff_111111
            end

            @points_container = stack width: 0.5, height: 1.0 do
            end
          end
        end

        @field = TAC::Simulator::Field.new(container: @field_container, season: :centerstage, simulation: nil)
        @nodes ||= []
        @unit = :inches
        @total_distance = 0

        @node_color = 0xff_00f000
        @node_hover_color = Gosu::Color::YELLOW
        @segment_color = 0xaa_00f000
        @node_radius = 6
        @segment_thickness = 2

        @font = CyberarmEngine::Text.new(font: THEME_BOLD_FONT, size: 18, border: true, static: true)
        @last_mouse_position = CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y)

        measure_path
        refresh_panel
      end

      def draw
        super

        @field.draw

        display_path

        if @field_container.hit?(window.mouse_x, window.mouse_y)
          x = (window.mouse_x - @field_container.x) / @field.scale - 72
          y = (window.mouse_y - @field_container.y) / @field.scale - 72

          @font.text = "X: #{inches_to_unit(x).round(2)} Y: #{inches_to_unit(y).round(2)} (#{@unit.to_s})"
          @font.x = window.mouse_x + 6
          @font.y = window.mouse_y - (@font.height / 2.0 + 24)
          @font.z = 100_001

          Gosu.draw_rect(
            window.mouse_x,
            @font.y - 6,
            @font.width + 12,
            @font.height + 12,
            0xaa_000000,
            100_000
          )

          @font.draw
        end
      end

      def update
        super

        current_state.request_repaint if window.mouse_x != @last_mouse_position.x || window.mouse_y != @last_mouse_position.y
        @last_mouse_position = CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y)

        @field.update

        measure_path
      end

      def button_down(id)
        super

        if @field_container.hit?(window.mouse_x, window.mouse_y)
          x = (window.mouse_x - @field_container.x) / @field.scale
          y = (window.mouse_y - @field_container.y) / @field.scale

          case id
          when Gosu::MS_LEFT # Add Node
            @nodes << CyberarmEngine::Vector.new(x, y, 0)

            measure_path

            refresh_panel

          when Gosu::MS_RIGHT # Delete Node
            result = @nodes.find do |node|
              Gosu.distance(node.x, node.y, x, y) <= @node_radius * 0.25
            end

            @nodes.delete(result) if result

            measure_path

            refresh_panel
          end
        end
      end

      def display_path
        x = (window.mouse_x - @field_container.x) / @field.scale
        y = (window.mouse_y - @field_container.y) / @field.scale

        last_node = @nodes.first

        @nodes.each_with_index do |current_node, i|
          mouse_near = Gosu.distance(current_node.x, current_node.y, x, y) <= @node_radius * 0.25

          Gosu.draw_circle(
            current_node.x * @field.scale + @field_container.x,
            current_node.y * @field.scale + @field_container.y,
            @node_radius, 7, mouse_near ? @node_hover_color : @node_color, @field_container.z + 1
          )

          next if i.zero?

          angle = Gosu.angle(
            last_node.x * @field.scale,
            last_node.y * @field.scale,
            current_node.x * @field.scale,
            current_node.y * @field.scale
          )

          distance = Gosu.distance(last_node.x, last_node.y, current_node.x, current_node.y) * @field.scale

          Gosu.rotate(angle, last_node.x * @field.scale + @field_container.x, last_node.y * @field.scale + @field_container.y) do
            Gosu.draw_rect(
              (@field_container.x + last_node.x * @field.scale) - (@segment_thickness / 2.0),
              (@field_container.y + last_node.y * @field.scale) - distance,
              @segment_thickness,
              distance,
              @segment_color,
              @field_container.z + 1
            )
          end

          last_node = current_node
        end
      end

      def measure_path
        @total_distance = 0

        v1 = @nodes.first
        @nodes.each_with_index do |v2, i|
          next if i.zero?

          @total_distance += Gosu.distance(
            v1.x + @field_container.x,
            v1.y + @field_container.y,
            v2.x + @field_container.x,
            v2.y + @field_container.y
          )

          v1 = v2
        end
      end

      def refresh_panel
        @nodes_count_label.value = "#{@nodes.count}"
        @total_distance_label.value = "#{inches_to_unit(@total_distance).round(2)}"
        @units_label.value = @unit.to_s.capitalize

        status_bar.recalculate
        status_bar.recalculate
        status_bar.recalculate

        # @points_container.clear do
          # v1 = @nodes.first
          # break unless v1

          # para "Vector #{inches_to_unit(v1.x).round}:#{inches_to_unit(v1.y).round} - 0 #{@unit.to_s.capitalize}"

          # @nodes.each_with_index do |v2, i|
          #   next if i.zero?

          #   distance = Gosu.distance(
          #     v1.x + @field_container.x,
          #     v1.y + @field_container.y,
          #     v2.x + @field_container.x,
          #     v2.y + @field_container.y
          #   )

            # para "Vector #{inches_to_unit(v1.x).round}:#{inches_to_unit(v1.y).round} - #{inches_to_unit(distance).round(2)} #{@unit.to_s.capitalize}"

            # v1 = v2
          # end
        # end
      end

      def inches_to_unit(inches)
        case @unit
        when :inches
          inches
        when :feet
          inches / 12.0
        when :millimeters
          inches * 25.4
        when :centimeters
          inches * 2.54
        when :meters
          inches * 0.0254
        end
      end
    end
  end
end