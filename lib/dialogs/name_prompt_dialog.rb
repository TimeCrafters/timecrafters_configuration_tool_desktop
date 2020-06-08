module TAC
  class Dialog
    class NamePromptDialog < Dialog
      def build
        background Gosu::Color::GRAY
        flow width: 1.0 do
          label "Name", width: 0.25, text_size: 18
          @name = edit_line @options[:renaming] ? @options[:renaming].name : "", width: 0.70, text_size: 18
        end

        flow width: 1.0 do
          button "Cancel", width: 0.475, text_size: 18 do
            close
          end

          button @options[:renaming] ? "Update" : "Add", width: 0.475, text_size: 18 do
            if @name.value.strip.empty?
              push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Name cannot be blank.\nName cannot only be whitespace.")
            else
              if @options[:renaming]
                @options[:callback_method].call(@options[:renaming], @name.value.strip)
              else
                @options[:callback_method].call(@name.value.strip)
              end

              close
            end
          end
        end
      end
    end
  end
end