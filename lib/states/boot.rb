module TAC
  class States
    class Boot < CyberarmEngine::GuiState
      def setup
        stack width: 1.0, height: 1.0 do
          background [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY, TAC::Palette::TIMECRAFTERS_TERTIARY, TAC::Palette::TIMECRAFTERS_PRIMARY]
        end

        @title_font = CyberarmEngine::Text.new(TAC::NAME, z: 100, size: 72, shadow: true, shadow_size: 3, font: THEME[:Label][:font])
        @logo = Gosu::Image.new("#{TAC::ROOT_PATH}/media/logo.png")

        @animator = CyberarmEngine::Animator.new(start_time: 0, duration: 3_000, from: 0, to: 255)
        @transition_color = Gosu::Color.new(0x00_000000)

        @next_state = USE_REDESIGN ? NewEditor : Editor
      end

      def draw
        super

        @title_font.draw
        @logo.draw(window.width / 2 - @logo.width / 2, window.height / 2 - @logo.height / 2, 99)
        Gosu.draw_rect(0, 0, window.width, window.height, @transition_color, 10_00)
      end

      def update
        super

        @title_font.x = window.width / 2 - @title_font.width / 2
        @title_font.y = window.height / 2 - (@logo.height / 2 + @title_font.height)

        @transition_color.alpha = @animator.transition(0, 255, :sine)

        push_state(@next_state) if @transition_color.alpha >= 255
      end

      def button_up(id)
        super

        push_state(@next_state)
      end
    end
  end
end