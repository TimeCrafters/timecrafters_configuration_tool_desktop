module TAC
  class States
    class Simulator < CyberarmEngine::GuiState
      def setup
        theme(THEME)

        stack width: 1.0, height: 0.1 do
          background [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY]
          label "#{TAC::NAME} ― Simulator", text_size: 28, color: Gosu::Color::BLACK
          button "Close", text_size: 18 do
            pop_state
          end
        end

        flow width: 1.0, height: 0.9 do
          background Gosu::Color::GRAY

          @field_container = stack width: 0.4, height: 1.0 do
            background Gosu::Color::WHITE
          end

          stack width: 0.6, height: 1.0 do
            background Gosu::Color::GREEN

            stack width: 1.0, height: 0.95 do
              # background Gosu::Color::YELLOW
              @source_code = edit_line "", width: 1.0, height: 1.0, text_size: 18
            end

            flow width: 1.0, height: 0.05 do
              background Gosu::Color::BLUE

              button "Run", text_size: 18, width: 0.49 do
                @simulation = TAC::Simulator::Simulation.new(source_code: @source_code.value, field_container: @field_container)
                @simulation.__start
              end
              button "Save", text_size: 18, width: 0.49
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