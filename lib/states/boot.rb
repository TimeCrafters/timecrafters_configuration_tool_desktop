module TAC
  class States
    class Boot < CyberarmEngine::GuiState
      def setup
        window.show_cursor = true

        stack width: 1.0, height: 1.0 do
          background [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY, TAC::Palette::TIMECRAFTERS_TERTIARY, TAC::Palette::TIMECRAFTERS_PRIMARY]
        end

        @title_font = CyberarmEngine::Text.new(TAC::NAME, z: 100, size: 72, border: true, border_size: 2, border_color: 0xff_000000, font: THEME[:TextBlock][:font], static:  true)
        @logo = Gosu::Image.new("#{TAC::MEDIA_PATH}/logo.png")

        @title_animator = CyberarmEngine::Animator.new(start_time: Gosu.milliseconds + 0, duration: 750, from: 0.0, to: 1.0, tween: :swing_from_to)
        @logo_animator = CyberarmEngine::Animator.new(start_time: Gosu.milliseconds + 750, duration: 1_000, from: 0.0, to: 1.0, tween: :swing_to)
        @transition_animator = CyberarmEngine::Animator.new(start_time: Gosu.milliseconds + 2_250, duration: 750, from: 0, to: 255, tween: :ease_out)
        @transition_color = Gosu::Color.new(0x00_111111)

        @next_state = Editor
      end

      def draw
        super

        @title_font.draw
        @logo.draw_rot(window.width / 2, window.height / 2, 99, 0, 0.5, 0.5, @logo_animator.transition, @logo_animator.transition)
        Gosu.draw_rect(0, 0, window.width, window.height, @transition_color, 10_00)
      end

      def update
        super

        request_repaint

        @title_font.x = window.width / 2 - @title_font.width / 2
        @title_font.y = (window.height / 2 - (@logo.height / 2 + @title_font.height)) * @title_animator.transition

        @transition_color.alpha = @transition_animator.transition

        if @transition_color.alpha >= 255
          pop_state
          push_state(@next_state)
        end
      end

      def button_down(id)
        super

        pop_state
        push_state(@next_state)
      end
    end
  end
end