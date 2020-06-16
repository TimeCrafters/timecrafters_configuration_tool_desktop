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
              button get_image("#{TAC::ROOT_PATH}/media/icons/right.png"), image_width: THEME_ICON_SIZE, width: 0.49 do
                begin
                  @simulation = TAC::Simulator::Simulation.new(source_code: @source_code.value, field_container: @field_container)
                  @simulation.__start
                rescue SyntaxError, NameError, NoMethodError, TypeError, ArgumentError => e
                  push_state(Dialog::AlertDialog, title: "#{e.class}", message: e)
                end
              end
              button get_image("#{TAC::ROOT_PATH}/media/icons/stop.png"), image_width: THEME_ICON_SIZE, width: 0.49 do
                @simulation.__queue.clear if @simulation
              end
              button get_image("#{TAC::ROOT_PATH}/media/icons/save.png"), image_width: THEME_ICON_SIZE, width: 0.49

              @simulation_status = label ""
            end

            stack width: 1.0, height: 0.95 do
              @source_code = edit_box "backward 100\nturn 90\nforward 100\nturn -90\nforward 100\nturn -90\nforward 100", width: 1.0, height: 1.0
            end
          end
        end
      end

      def draw
        super

        Gosu.flush
        @simulation.__draw if @simulation
      end

      def update
        super

        @simulation.__update if @simulation
      end
    end
  end
end