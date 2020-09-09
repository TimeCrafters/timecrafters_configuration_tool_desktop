module TAC
  class Dialog
    class TACNETStatusDialog < Dialog
      def build
        background Gosu::Color::GRAY
        @message_label = label $window.backend.tacnet.full_status

        button "Close", width: 1.0 do
          close
        end

        @timer = CyberarmEngine::Timer.new(1000.0) do
          @message_label.value = $window.backend.tacnet.full_status
        end
      end

      def update
        super

        @timer.update
      end
    end
  end
end