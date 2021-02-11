module TAC
  class Dialog
    class AlertDialog < Dialog
      def build
        background Gosu::Color::GRAY
        label @options[:message]

        button "Close", width: 1.0, margin_top: THEME_DIALOG_BUTTON_PADDING do
          try_commit
        end
      end

      def try_commit
        close
      end
    end
  end
end