module TAC
  class Dialog
    class NamePromptDialog < Dialog
      def build
        background Gosu::Color::GRAY
        flow width: 1.0 do
          label "Name", width: 0.25
          @name = edit_line @options[:renaming] ? @options[:renaming].name : "", filter: method(:filter), width: 0.70
        end
        @name_error = label "", color: TAC::Palette::TACNET_CONNECTION_ERROR
        @name_error.hide

        flow width: 1.0 do
          button "Cancel", width: 0.475 do
            close
          end

          accept_label = @options[:renaming] ? "Update" : "Add"
          accept_label = @options[:accept_label] if @options[:accept_label]

          button accept_label, width: 0.475 do
            if @name.value.strip.empty?
              @name_error.value = "Name cannot be blank.\nName cannot only be whitespace."
              @name_error.show
            elsif @options[:list] && @options[:list].find { |i| i.name == @name.value.strip }
              @name_error.value = "Name is not unique!"
              @name_error.show
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

      def filter(text)
        text.match(/[A-Za-z0-9,._\-]/) ? text : ""
      end
    end
  end
end