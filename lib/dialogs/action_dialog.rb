module TAC
  class Dialog
    class ActionDialog < Dialog
      def build
        background Gosu::Color::GRAY

        @type = @options[:action].type if @options[:action]

        label "Name"
        @name_error = label "Error", color: TAC::Palette::TACNET_CONNECTION_ERROR
        @name_error.hide
        @name = edit_line @options[:action] ? @options[:action].name : "", width: 1.0

        label "Comment"
        @comment = edit_line @options[:action] ? @options[:action].comment : "", width: 1.0

        flow width: 1.0 do
          button "Cancel", width: 0.475 do
            close
          end

          button @options[:action] ? "Update" : "Add", width: 0.475 do |b|
            if valid?
              if @options[:action]
                @options[:callback_method].call(@options[:action], @name.value.strip, @comment.value.strip)
              else
                @options[:callback_method].call(@name.value.strip, @comment.value.strip)
              end

              close
            end
          end
        end
      end

      def valid?
        valid = true

        if @name.value.strip.empty?
          @name_error.value = "Error: Name cannot be blank\n or only whitespace."
          @name_error.show
          valid = false
        else
          @name_error.value = ""
          @name_error.hide
        end

        return valid
      end
    end
  end
end
