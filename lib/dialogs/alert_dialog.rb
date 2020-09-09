module TAC
  class Dialog
    class AlertDialog < Dialog
      def build
        background Gosu::Color::GRAY
        label @options[:message]

        button "Close", width: 1.0, margin_top: THEME_DIALOG_BUTTON_PADDING do
          close
        end
      end
    end
  end
end