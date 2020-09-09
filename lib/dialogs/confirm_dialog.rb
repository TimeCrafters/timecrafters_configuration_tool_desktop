module TAC
  class Dialog
    class ConfirmDialog < Dialog
      def build
        @dialog_root.style.border_color = [ Palette::ALERT, darken(Palette::ALERT, 50) ]
        @titlebar.style.background = [ Palette::ALERT, darken(Palette::ALERT, 50) ]

        background Gosu::Color::GRAY
        label @options[:message]

        flow width: 1.0, margin_top: THEME_DIALOG_BUTTON_PADDING do
          button "Cancel", width: 0.475 do
            close
          end
          button "Okay", width: 0.475, **TAC::THEME_DANGER_BUTTON do
            close

            @options[:callback_method].call
          end
        end
      end
    end
  end
end