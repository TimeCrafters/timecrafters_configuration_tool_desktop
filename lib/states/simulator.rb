module TAC
  class States
    class Simulator < CyberarmEngine::GuiState
      def setup
        theme(THEME)

        stack width: 1.0, height: 0.1 do
          background THEME_HEADER_BACKGROUND
          label "#{TAC::NAME} ― Simulator", bold: true, text_size: THEME_HEADING_TEXT_SIZE
          button "Close" do
            pop_state
          end
        end

        flow width: 1.0, height: 0.9 do
          @field_container = stack width: 0.4, height: 1.0 do
            background Gosu::Color.new(0xff_333333)..Gosu::Color::BLACK
          end

          stack width: 0.6, height: 1.0 do
            background Gosu::Color.new(0x88_ff8800)

            flow width: 1.0, height: 0.05 do
              button get_image("#{TAC::ROOT_PATH}/media/icons/right.png"), image_width: THEME_ICON_SIZE, width: 0.49, tip: "Run simulation" do
                begin
                  @simulation = TAC::Simulator::Simulation.new(source_code: @source_code.value, field_container: @field_container)
                  @simulation.start
                rescue SyntaxError, NameError, NoMethodError, TypeError, ArgumentError => e
                  puts e.backtrace.reverse.join("\n")
                  puts e
                  push_state(Dialog::AlertDialog, title: "#{e.class}", message: e)
                end
              end
              button get_image("#{TAC::ROOT_PATH}/media/icons/stop.png"), image_width: THEME_ICON_SIZE, width: 0.49, tip: "Stop simulation" do
                @simulation.queue.clear if @simulation
              end
              button get_image("#{TAC::ROOT_PATH}/media/icons/save.png"), image_width: THEME_ICON_SIZE, width: 0.49, tip: "Save source code" do
                File.open("#{TAC::ROOT_PATH}/data/simulator.rb", "w") { |f| f.write @source_code.value }
              end

              @simulation_status = label ""
            end

            stack width: 1.0, height: 0.95 do
              source_code = ""
              if File.exist?("#{TAC::ROOT_PATH}/data/simulator.rb")
                source_code = File.read("#{TAC::ROOT_PATH}/data/simulator.rb")
              else
                source_code =
"robot = create_robot(alliance: :blue, width: 18, depth: 18)
robot.backward 100
robot.turn 90
robot.forward 100
robot.turn -90
robot.forward 100
robot.turn -90
robot.forward 100"
              end
              @source_code = edit_box source_code, width: 1.0, height: 1.0
            end
          end
        end
      end

      def draw
        super

        Gosu.flush
        @simulation.draw if @simulation
      end

      def update
        super

        @simulation.update if @simulation
      end
    end
  end
end