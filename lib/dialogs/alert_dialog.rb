module TAC
  class Dialog
    class AlertDialog < Dialog
      def build
        background Gosu::Color::GRAY
        label @options[:message], text_size: 18

        button "Close", width: 1.0, text_size: 18 do
          close
        end
      end
    end
  end
end