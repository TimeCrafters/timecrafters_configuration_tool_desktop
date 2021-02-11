module TAC
  class Pages
    class Simulator < Page
      SOURCE_FILE_PATH = "#{TAC::ROOT_PATH}/data/simulator.rb"
      def setup
        header_bar("Simulator")

        menu_bar.clear do
          button get_image("#{TAC::ROOT_PATH}/media/icons/right.png"), tip: "Run Simulation", image_height: 1.0 do
            save_source

            begin
              @simulation_start_time = Gosu.milliseconds
              @simulation = TAC::Simulator::Simulation.new(source_code: @source_code.value, field_container: @field_container)
              @simulation.start
            rescue SyntaxError, NameError, NoMethodError, TypeError, ArgumentError => e
              puts e.backtrace.reverse.join("\n")
              puts e
              push_state(Dialog::AlertDialog, title: "#{e.class}", message: e)
            end
          end

          button get_image("#{TAC::ROOT_PATH}/media/icons/stop.png"), tip: "Stop Simulation", image_height: 1.0 do
            @simulation.robots.each { |robot| robot.queue.clear } if @simulation
          end

          button get_image("#{TAC::ROOT_PATH}/media/icons/save.png"), tip: "Save", image_height: 1.0 do
            save_source
          end
        end

        status_bar.clear do
          @simulation_status = label ""
        end

        body.clear do
          flow(width: 1.0, height: 1.0) do
            @field_container = stack width: 0.4, height: 1.0 do
              background 0xff_111111
            end

            stack(width: 0.6, height: 1.0) do
              source_code =
"robot = create_robot(alliance: :blue, width: 18, depth: 18)
robot.backward 100
robot.turn 90
robot.forward 100
robot.turn -90
robot.forward 100
robot.turn -90
robot.forward 100"

              source_code = File.read(SOURCE_FILE_PATH) if File.exists?(SOURCE_FILE_PATH)

              @source_code = edit_box source_code, width: 1.0, height: 1.0
            end
          end
        end
      end

      def save_source
        File.open(SOURCE_FILE_PATH, "w") { |f| f.write @source_code.value }
        @simulation_status.value = "Saved source to #{SOURCE_FILE_PATH}"
      end

      def blur
        @simulation.robots.each { |robot| robot.queue.clear } if @simulation
        save_source
      end

      def draw
        @simulation.draw if @simulation
      end

      def update
        return unless @simulation

        @simulation.update

        unless @simulation.robots.all? { |robot| robot.queue.empty? } # Only update clock if simulation is running
          @simulation_status.value = "Time: #{((Gosu.milliseconds - @simulation_start_time) / 1000.0).round(1)} seconds" if @simulation_start_time
        end
      end
    end
  end
end