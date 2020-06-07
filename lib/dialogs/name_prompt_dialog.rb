module TAC
  class Dialog
    class NamePromptDialog < Dialog
      def build
        background Gosu::Color::GRAY
        label @options[:subtitle]

        flow width: 1.0 do
          label "Name", width: 0.25
          edit_line "", width: 0.70
        end

        flow width: 1.0 do
          button "Cancel", width: 0.475 do
            close
          end

          button @options[:submit_label], width: 0.475 do
            @options[:callback].call(self)
          end
        end
      end
    end
  end
end