module TAC
  class Dialog
    class NamePromptDialog < Dialog
      NameStub = Struct.new(:name)

      def build
        background Gosu::Color::GRAY
        label "Name", width: 1.0, text_align: :center
        @name_error = label "", color: TAC::Palette::TACNET_CONNECTION_ERROR
        @name_error.hide
        @name = edit_line @options[:renaming] ? @options[:renaming].name : "", filter: method(:name_filter), width: 1.0

        @name.subscribe(:changed) do |sender, value|
          valid?
        end

        flow width: 1.0, margin_top: THEME_DIALOG_BUTTON_PADDING do
          button "Cancel", width: 0.475 do
            close
          end

          accept_label = @options[:renaming] ? "Update" : "Add"
          accept_label = @options[:accept_label] if @options[:accept_label]

          button accept_label, width: 0.475 do
            try_commit
          end
        end
      end

      def try_commit
        if valid?
          if @options[:renaming]
            @options[:callback_method].call(@options[:renaming], @name.value.strip)
          else
            @options[:callback_method].call(@name.value.strip)
          end

          close
        end
      end

      def valid?
        name = @name.value.strip

        if @name.value.strip.empty?
          @name_error.value = "Name cannot be blank.\nName cannot only be whitespace."
          @name_error.show

          return false

        ### TODO: Handle case when renaming a cloned Group
        # elsif @options[:renaming] && @options[:renaming].name == name
        #   @name_error.value = ""
        #   @name_error.hide

        #   return true

        elsif @options[:list] && @options[:list].find { |i| i.name == name }
          @name_error.value = "Name is not unique!"
          @name_error.show

          return false
        else
          @name_error.value = ""
          @name_error.hide

          return true
        end
      end
    end
  end
end