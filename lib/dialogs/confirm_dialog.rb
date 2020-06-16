module TAC
  class Dialog
    class ConfirmDialog < Dialog
      def build
        background Gosu::Color::GRAY
        label @options[:message]

        flow width: 1.0 do
          button "Cancel", width: 0.475 do
            close
          end
          button "Okay", width: 0.475 do
            close

            @options[:callback_method].call
          end
        end
      end
    end
  end
end