module TAC
  class Dialog < CyberarmEngine::GuiState
    def setup
      theme(THEME)
      background Gosu::Color.new(0x88_000000)

      @title = @options[:title] ? @options[:title] : "#{self.class}"
      @window_width, @window_height = window.width, window.height
      @previous_state = window.previous_state

      @dialog_root = stack width: 250, height: 400, border_thickness: 2, border_color: [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY] do
        # Title bar
        flow width: 1.0, height: 0.1 do
          background [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY]

          # title
          flow width: 0.9 do
            label @title
          end

          # Buttons
          flow width: 0.1 do
            button "X", text_size: 24 do
              close
            end
          end
        end

        # Dialog body
        stack width: 1.0, height: 0.9 do
          build
        end
      end

      center_dialog
    end

    def build
    end

    def center_dialog
      @dialog_root.style.x = window.width / 2 - @dialog_root.style.width / 2
      @dialog_root.style.y = window.height / 2 - @dialog_root.style.height / 2
    end

    def draw
      @previous_state.draw
      Gosu.flush

      super
    end

    def update
      super

      if window.width != @window_width or window.height != @window_height
        center_dialog

        @window_width, @window_height = window.width, window.height
      end
    end

    def close
      $window.pop_state
    end
  end
end