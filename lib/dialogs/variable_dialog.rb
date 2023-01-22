module TAC
  class Dialog
    class VariableDialog < Dialog
      def build
        background Gosu::Color::GRAY

        @type = @options[:variable].type if @options[:variable]

        label "Name", width: 1.0, text_align: :center
        @name_error = label "Error", color: TAC::Palette::TACNET_CONNECTION_ERROR
        @name_error.hide
        @name = edit_line @options[:variable] ? @options[:variable].name : "", filter: method(:name_filter), width: 1.0, autofocus: true, focus: true
        @name.subscribe(:changed) do |sender, value|
          valid?
        end

        label "Type", width: 1.0, text_align: :center
        @type_error = label "Error", color: TAC::Palette::TACNET_CONNECTION_ERROR
        @type_error.hide

        @var_type = list_box items: [:float, :double, :integer, :long, :string, :boolean], choose: @type ? @type : :double, width: 1.0 do |item|
          @type = item.to_sym

          if @type == :boolean
            @value.hide
            @value_boolean.show
          else
            @value.show
            @value_boolean.hide
          end

          valid?
        end

        @type ||= @var_type.value.to_sym

        @value_container = stack width: 1.0 do
          label "Value", width: 1.0, text_align: :center
          @value_error = label "Error", color: TAC::Palette::TACNET_CONNECTION_ERROR
          @value_error.hide
          @value = edit_line @options[:variable] ? @options[:variable].value : "", width: 1.0
          @value_boolean = check_box "Boolean", checked: @options[:variable] ? @options[:variable].value == "true" : false

          @value.subscribe(:changed) do |sender, value|
            valid?
          end

          unless @options[:variable] && @options[:variable].type == :boolean
            @value_boolean.hide
          else
            @value.hide
          end
        end

        flow width: 1.0, margin_top: THEME_DIALOG_BUTTON_PADDING do
          button "Cancel", width: 0.5 do
            close
          end

          button @options[:variable] ? "Update" : "Add", width: 0.5 do |b|
            try_commit
          end
        end
      end

      def try_commit
        if valid?
          value = @type == :boolean ? @value_boolean.value.to_s : @value.value.strip

          if @options[:variable]
            @options[:callback_method].call(@options[:variable], @name.value.strip, @type, value)
          else
            @options[:callback_method].call(@name.value.strip, @type, value)
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

        ### Don't error if renaming variable to itself
        elsif @options[:variable] && @options[:variable].name == name
          @name_error.value = ""
          @name_error.hide

        elsif @options[:list].find { |variable| variable.name == name }
          @name_error.value = "Error: Name is not unique!"
          @name_error.show
          valid = false
        end

        if not @type
          @type_error.value = "Error: Type not set."
          @type_error.show
          valid = false
        end

        if [:integer, :float, :double, :long].include?(@type)
          if @value.value.strip.empty?
            @value_error.value = "Error: Numeric value cannot be blank or only whitespace."
            @value_error.show
            valid = false

          elsif [:integer, :long].include?(@type)
            begin
              Integer(@value.value.strip)
            rescue
              @value_error.value = "Error: Invalid value, expected whole number."
              @value_error.show
              valid = false
            end

          elsif [:float, :double].include?(@type)
            begin
              Float(@value.value.strip)
            rescue
              @value_error.value = "Error: Invalid value, expected decimal number."
              @value_error.show
              valid = false
            end
          end

        elsif @type == :string
          if @value.value.strip.empty?
            @value_error.value = "Error: Value cannot be blank or only whitespace."
            @value_error.show
            valid = false
          end

        elsif @type == :boolean

        else
          @value_error.value = "Error: Type not set or type #{@type.inspect} is not valid."
          @value_error.show
          valid = false
        end

        if valid
          @value_error.value = ""
          @value_error.hide
          @type_error.value = ""
          @type_error.hide
        end

        return valid
      end
    end
  end
end
