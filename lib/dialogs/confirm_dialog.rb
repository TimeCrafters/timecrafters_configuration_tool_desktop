module TAC
  class Dialog
    class ConfirmDialog < Dialog
      def build
        @dangerous = @options[:dangerous]
        @dangerous ||= false

        color = @dangerous ? Palette::DANGEROUS : Palette::ALERT

        @dialog_root.style.default[:border_color] = [ color, darken(color, 50) ]
        @titlebar.style.default[:background] = [ color, darken(color, 50) ]

        background Gosu::Color::GRAY
        label @options[:message]

        flow width: 1.0, margin_top: THEME_DIALOG_BUTTON_PADDING do
          button "Cancel", width: 0.5 do
            close
          end

          button "Proceed", width: 0.5, **TAC::THEME_DANGER_BUTTON do
            try_commit(true)
          end
        end

        def try_commit(force = false)
          if !@dangerous
            close

            @options[:callback_method].call
          elsif @dangerous && force
            close

            @options[:callback_method].call
          end
        end
      end
    end
  end
end