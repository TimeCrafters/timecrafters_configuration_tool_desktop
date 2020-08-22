module TAC
  class Dialog
    class VariableDialog < Dialog
      def build
        background Gosu::Color::GRAY

        @type = @options[:variable].type if @options[:variable]

        label "Name"
        @name_error = label "Error", color: TAC::Palette::TACNET_CONNECTION_ERROR
        @name_error.hide
        @name = edit_line @options[:variable] ? @options[:variable].name : "", width: 1.0

        label "Type"
        @type_error = label "Error", color: TAC::Palette::TACNET_CONNECTION_ERROR
        @type_error.hide

        @var_type = list_box items: [:float, :double, :integer, :long, :string, :boolean], choose: @type ? @type : :double, width: 1.0 do |item|
          @type = item
        end

        @value_container = stack width: 1.0 do
          label "Value"
          @value_error = label "Error", color: TAC::Palette::TACNET_CONNECTION_ERROR
          @value_error.hide
          @value = edit_line @options[:variable] ? @options[:variable].value : "", width: 1.0
          @value_boolean = check_box "Variable", checked: @options[:variable] ? @options[:variable].value == true : false
        end

        flow width: 1.0 do
          button "Cancel", width: 0.475 do
            close
          end

          button @options[:variable] ? "Update" : "Add", width: 0.475 do |b|
            if valid?
              if @options[:variable]
                @options[:callback_method].call(@options[:variable], @name.value.strip, @type, @value.value.strip)
              else
                @options[:callback_method].call(@name.value.strip, @type, @value.value.strip)
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

        if not @type
          @type_error.value = "Error: Type not set."
          @type_error.show
          valid = false
        else
          @type_error.value = ""
          @type_error.hide
        end

        if [:integer, :float, :double, :long].include?(@type)
          if @value.value.strip.empty?
            @value_error.value = "Error: Value cannot be blank\n or only whitespace."
            @value_error.show
            valid = false

          elsif [:integer, :long].include?(@type)
            begin
              Integer(@value.value.strip)
            rescue
              @value_error.value = "Error: Invalid value,\nexpected whole number."
              @value_error.show
              valid = false
            end

          elsif [:float, :double].include?(@type)
            begin
              Float(@value.value.strip)
            rescue
              @value_error.value = "Error: Invalid value,\nexpected decimal number."
              @value_error.show
              valid = false
            end
          else
            @value_error.value = ""
            @value_error.hide
          end

        elsif @type == :string
          if @value.value.strip.empty?
            @value_error.value = "Error: Value cannot be blank\n or only whitespace."
            @value_error.show
            valid = false
          end

        elsif @type == :boolean
          @value_error.value = "Error: Boolean not yet supported."
          @value_error.show
          valid = false

        else
          @value_error.value = "Error: Type not set."
          @value_error.show
          valid = false
        end

        return valid
      end
    end
  end
end
