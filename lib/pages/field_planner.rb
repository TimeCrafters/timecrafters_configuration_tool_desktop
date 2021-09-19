module TAC
  class Pages
    class FieldPlanner < Page
      def setup
        header_bar("Field Planner")

        body.clear do
          flow(width: 1.0, height: 1.0) do
            @field_container = stack width: 0.5, height: 1.0 do
              background 0xff_111111
            end

            @points_container = stack width: 0.5, height: 1.0 do
            end
          end
        end

        @field = TAC::Simulator::Field.new(container: @field_container, season: :skystone, simulation: nil)
        @nodes = []
        @unit = :inches
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
            3, 7
          )

          next if i.zero?

          Gosu.draw_line(
            last_node.x * @field.scale + @field_container.x,
            last_node.y * @field.scale + @field_container.y,
            Gosu::Color::GREEN,
            current_node.x * @field.scale + @field_container.x,
            current_node.y * @field.scale + @field_container.y,
            Gosu::Color::GREEN,
            3
          )

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
        @points_container.clear do
          title "Nodes: #{@nodes.count} - Length: #{@total_distance.round}"

          @nodes.each do |v|
            para "Vector #{v.x.round}:#{v.y.round}"
          end
        end
      end
    end
  end
end