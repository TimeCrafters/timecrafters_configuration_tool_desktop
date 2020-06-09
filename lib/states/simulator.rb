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

        flow width: 1.0, height: 1.0 do
          background [Gosu::Color::GRAY, Gosu::Color::BLACK]
        end
      end
    end
  end
end