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
              refresh_panel
            end
          end
        end

        status_bar.clear do
          flow(width: 1.0, height: 1.0) do
            tagline "Nodes:"
            @nodes_count_label = tagline "0"

            tagline "Total Distance:"
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

        @field = TAC::Simulator::Field.new(container: @field_container, season: :freight_frenzy, simulation: nil)
        @nodes ||= []
        @unit = :inches
        @total_distance = 0

        @node_color = Gosu::Color.rgb(200, 100, 50)
        @segment_color = Gosu::Color.rgb(255, 127, 0)
        @node_radius = 6
        @segment_thickness = 2

        refresh_panel
      end

      def draw
        super

        @field.draw

        display_path
      end

      def update
        super

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
              Gosu.distance(
                node.x,
                node.y,
                x,
                y
              ) <= 1.5
            end

            @nodes.delete(result) if result

            measure_path

            refresh_panel
          end
        end
      end

      def display_path
        last_node = @nodes.first

        @nodes.each_with_index do |current_node, i|
          Gosu.draw_circle(
            current_node.x * @field.scale + @field_container.x,
            current_node.y * @field.scale + @field_container.y,
            @node_radius, 7, @node_color, 10
          )

          next if i.zero?

          angle = Gosu.angle(
            last_node.x * @field.scale,
            last_node.y * @field.scale,
            current_node.x * @field.scale,
            current_node.y * @field.scale
          )

          distance = Gosu.distance(last_node.x, last_node.y, current_node.x, current_node.y) * @field.scale

          Gosu.rotate(angle, last_node.x * @field.scale, last_node.y * @field.scale) do
            Gosu.draw_rect(
              (@field_container.x + last_node.x * @field.scale) - (@segment_thickness / 2.0),
              (@field_container.y + last_node.y * @field.scale) - distance,
              @segment_thickness,
              distance,
              @segment_color
            )
          end

          # Gosu.draw_line(
          #   last_node.x * @field.scale + @field_container.x,
          #   last_node.y * @field.scale + @field_container.y,
          #   @segment_color,
          #   current_node.x * @field.scale + @field_container.x,
          #   current_node.y * @field.scale + @field_container.y,
          #   @segment_color,
          #   3
          # )

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

        @points_container.clear do
          v1 = @nodes.first
          break unless v1

          para "Vector #{inches_to_unit(v1.x).round}:#{inches_to_unit(v1.y).round} - 0 #{@unit.to_s.capitalize}"

          @nodes.each_with_index do |v2, i|
            next if i.zero?

            distance = Gosu.distance(
              v1.x + @field_container.x,
              v1.y + @field_container.y,
              v2.x + @field_container.x,
              v2.y + @field_container.y
            )

            para "Vector #{inches_to_unit(v1.x).round}:#{inches_to_unit(v1.y).round} - #{inches_to_unit(distance).round(2)} #{@unit.to_s.capitalize}"

            v1 = v2
          end
        end
      end

      def inches_to_unit(inches)
        case @unit
        when :inches
          inches
        when :feet
          inches / 12.0
        when :millimeters
          inches / 0.254
        when :centimeters
          inches / 2.54
        when :meters
          inches / 25.4
        end
      end
    end
  end
end