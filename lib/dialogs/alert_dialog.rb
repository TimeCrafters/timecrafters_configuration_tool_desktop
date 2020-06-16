module TAC
  class Dialog
    class AlertDialog < Dialog
      def build
        background Gosu::Color::GRAY
        label @options[:message]

        button "Close", width: 1.0 do
          close
        end
      end
    end
  end
end