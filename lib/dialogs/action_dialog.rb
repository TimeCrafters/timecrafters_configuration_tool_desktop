module TAC
  class Dialog
    class ActionDialog < Dialog
      def build
        background Gosu::Color::GRAY

        label "Name", width: 1.0, text_align: :center
        @name_error = label "Error", color: TAC::Palette::TACNET_CONNECTION_ERROR
        @name_error.hide
        @name = edit_line @options[:action] ? @options[:action].name : "", filter: method(:name_filter), width: 1.0, autofocus: true
        @name.subscribe(:changed) do |sender, value|
          valid?
        end

        label "Comment", width: 1.0, text_align: :center
        @comment = edit_line @options[:action] ? @options[:action].comment : "", width: 1.0

        flow width: 1.0, margin_top: THEME_DIALOG_BUTTON_PADDING do
          button "Cancel", width: 0.475 do
            close
          end

          button @options[:action] ? @options[:accept_label] ? @options[:accept_label] : "Update" : "Add", width: 0.475 do |b|
            try_commit
          end
        end
      end

      def  try_commit
        if valid?
          if @options[:action]
            @options[:callback_method].call(@options[:action], @name.value.strip, @comment.value.strip)
          else
            @options[:callback_method].call(@name.value.strip, @comment.value.strip)
          end

          close
        end
      end

      def valid?
        valid = true
        name = @name.value.strip

        if name.empty?
          @name_error.value = "Error: Name cannot be blank or only whitespace."
          @name_error.show
          valid = false

        ### TODO: Handle case when renaming a cloned Action
        elsif !@options[:cloning] && @options[:action] && @options[:action].name == name
          @name_error.value = ""
          @name_error.hide

        elsif @options[:list].find { |action| action.name == name}
          @name_error.value = "Error: Name is not unique!"
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
