module TAC
  class Dialog
    class TACNETStatusDialog < Dialog
      def build
        background Gosu::Color::GRAY
        @message_label = label CyberarmEngine::Window.instance.backend.tacnet.full_status

        button "Close", width: 1.0, margin_top: THEME_DIALOG_BUTTON_PADDING do
          try_commit
        end

        @timer = CyberarmEngine::Timer.new(1000.0) do
          @message_label.value = CyberarmEngine::Window.instance.backend.tacnet.full_status
        end
      end

      def try_commit
        close
      end

      def update
        super

        @timer.update
      end
    end
  end
end