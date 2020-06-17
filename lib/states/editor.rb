module TAC
  class States
    class Editor < CyberarmEngine::GuiState
      def setup
        @active_group = nil
        @active_action = nil

        theme(THEME)

        stack width: 1.0, height: 1.0 do
          stack width: 1.0, height: 0.1, border_thickness: 1, border_color: [0, 0, Gosu::Color::BLACK, 0] do
            background THEME_HEADER_BACKGROUND

            flow width: 1.0, height: 1.0 do
              stack width: 0.60 do
                label TAC::NAME, bold: true, text_size: THEME_HEADING_TEXT_SIZE
                flow width: 1.0 do
                  flow width: 0.3 do
                    label "Group: "
                    @active_group_label = label ""
                  end

                  flow width: 0.3 do
                    label "Action: "
                    @active_action_label = label ""
                  end

                  flow width: 0.395 do
                    button get_image("#{TAC::ROOT_PATH}/media/icons/right.png"), image_width: THEME_ICON_SIZE, margin_left: 10, tip: "Simulator" do
                      push_state(Simulator)
                    end
                    button get_image("#{TAC::ROOT_PATH}/media/icons/menuList.png"), image_width: THEME_ICON_SIZE, margin_left: 10, tip: "Manage presets" do
                      push_state(ManagePresets)
                    end
                    button get_image("#{TAC::ROOT_PATH}/media/icons/wrench.png"), image_width: THEME_ICON_SIZE, margin_left: 10, tip: "Manage configurations" do
                      push_state(ManageConfigurations)
                    end
                    button get_image("#{TAC::ROOT_PATH}/media/icons/save.png"), image_width: THEME_ICON_SIZE, margin_left: 10, tip: "Save config and settings to disk" do
                      window.backend.save_config(window.backend.settings.config)
                      window.backend.save_settings
                    end
                    button get_image("#{TAC::ROOT_PATH}/media/icons/export.png"), image_width: THEME_ICON_SIZE, margin_left: 10, tip: "Upload local config to remote, if connected." do
                      window.backend.upload_config(window.backend.settings.config)
                    end
                    button get_image("#{TAC::ROOT_PATH}/media/icons/import.png"), image_width: THEME_ICON_SIZE, margin_left: 10, tip: "Download remote config, if connected." do
                      window.backend.download_config(window.backend.settings.config)
                    end
                  end
                end
              end

              flow width: 0.399 do
                stack width: 0.5 do
                  label "TACNET v#{TACNET::Packet::PROTOCOL_VERSION}", color: TAC::Palette::TACNET_PRIMARY, text_shadow: true, text_shadow_size: 1, text_shadow_color: Gosu::Color::BLACK
                  flow width: 1.0 do
                    @tacnet_hostname = edit_line "#{window.backend.settings.hostname}", width: 0.5, margin_right: 0
                    @tacnet_hostname.subscribe(:changed) do |caller, value|
                      window.backend.settings.hostname = value
                      window.backend.settings_changed!
                    end

                    label ":", margin: 0, padding: 0, padding_top: 3

                    @tacnet_port = edit_line "#{window.backend.settings.port}", width: 0.2, margin_left: 0
                    @tacnet_port.subscribe(:changed) do |caller, value|
                      window.backend.settings.port = Integer(value)
                      window.backend.settings_changed!
                    end
                  end
                end

                stack width: 0.499 do
                  @tacnet_status = label "Not Connected", background: TAC::Palette::TACNET_NOT_CONNECTED, width: 1.0, padding: 5, margin_top: 2, border_thickness: 1, border_color: Gosu::Color::GRAY
                  flow width: 1.0 do
                    @tacnet_connection_button = button "Connect", width: 0.475 do
                      case window.backend.tacnet.status
                      when :connected, :connecting
                        window.backend.tacnet.close
                      when :not_connected, :connection_error
                        window.backend.tacnet.connect(@tacnet_hostname.value, @tacnet_port.value)
                      end
                    end
                    button get_image("#{TAC::ROOT_PATH}/media/icons/information.png"), image_width: THEME_ICON_SIZE, width: 0.475 do
                      push_state(Dialog::AlertDialog, title: "TACNET Status", message: window.backend.tacnet.full_status)
                    end
                  end
                end
              end
            end
          end

          @content = flow width: 1.0, height: 0.9 do
            background THEME_CONTENT_BACKGROUND
            stack width: 0.333, height: 1.0, border_thickness: 1, border_color: [0, Gosu::Color::BLACK, 0, 0] do
              flow do
                label "Groups", text_size: THEME_SUBHEADING_TEXT_SIZE
                button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: THEME_ICON_SIZE, tip: "Add group" do
                  push_state(TAC::Dialog::NamePromptDialog, title: "Create Group", list: window.backend.config.groups, callback_method: method(:create_group))
                end
                button get_image("#{TAC::ROOT_PATH}/media/icons/button2.png"), image_width: THEME_ICON_SIZE, tip: "Clone currently selected group" do
                  if @active_group
                    push_state(Dialog::NamePromptDialog, title: "Clone Group", renaming: @active_group, accept_label: "Clone", list: window.backend.config.groups, callback_method: proc { |group, name|
                      clone = TAC::Config::Group.from_json( JSON.parse( @active_group.to_json, symbolize_names: true ))
                      clone.name = "#{name}"
                      window.backend.config.groups << clone
                      window.backend.config_changed!

                      populate_groups_list
                    })
                  end
                end
                button get_image("#{TAC::ROOT_PATH}/media/icons/save.png"), image_width: THEME_ICON_SIZE, tip: "Save group as preset" do
                  if @active_group
                    push_state(Dialog::NamePromptDialog, title: "Save Group Preset", renaming: @active_group, accept_label: "Save", list: window.backend.config.presets.actions, callback_method: proc { |action, name|
                    })
                  end
                end
              end

              @groups_list = stack width: 1.0 do
              end
            end
            stack width: 0.333, height: 1.0, border_thickness: 1, border_color: [0, Gosu::Color::BLACK, 0, 0] do
              flow do
                label "Actions", text_size: THEME_SUBHEADING_TEXT_SIZE
                button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: THEME_ICON_SIZE, tip: "Add action" do
                  if @active_group
                    push_state(TAC::Dialog::NamePromptDialog, title: "Create Action", list: @active_group.actions, callback_method: method(:create_action))
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create action,\nno group selected.")
                  end
                end
                button get_image("#{TAC::ROOT_PATH}/media/icons/button2.png"), image_width: THEME_ICON_SIZE, tip: "Clone currently selected action" do
                  if @active_group && @active_action
                    push_state(Dialog::NamePromptDialog, title: "Clone Action", renaming: @active_action, accept_label: "Clone", list: @active_group.actions, callback_method: proc { |action, name|
                    clone = TAC::Config::Action.from_json( JSON.parse( @active_action.to_json, symbolize_names: true ))
                    clone.name = name
                    @active_group.actions << clone
                    window.backend.config_changed!

                    populate_actions_list(@active_group)
                    })
                  end
                end
                button get_image("#{TAC::ROOT_PATH}/media/icons/save.png"), image_width: THEME_ICON_SIZE, tip: "Save action as preset" do
                  if @active_action
                    push_state(Dialog::NamePromptDialog, title: "Save Action Preset", renaming: @active_action, accept_label: "Save", list: window.backend.config.presets.actions, callback_method: proc { |action, name|
                    })
                  end
                end
              end

              @actions_list = stack width: 1.0 do
              end
            end
            stack width: 0.331, height: 1.0 do
              flow do
                label "Variables", text_size: THEME_SUBHEADING_TEXT_SIZE
                button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: THEME_ICON_SIZE, tip: "Add variable" do
                  if @active_action
                    push_state(TAC::Dialog::VariableDialog, title: "Create Variable", callback_method: method(:create_variable))
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create variable,\nno action selected.")
                  end
                end
              end

              @variables_list = stack width: 1.0 do
              end
            end
          end
        end

        unless window.backend.settings.config
          push_state(ManageConfigurations)
        else
          populate_groups_list
        end

        @tacnet_status_monitor = CyberarmEngine::Timer.new(250) do
          case window.backend.tacnet.status
          when :connected
            @tacnet_status.value = "Connected"
            @tacnet_status.background = TAC::Palette::TACNET_CONNECTED

            @tacnet_connection_button.value = "Disconnect"
          when :connecting
            @tacnet_status.value = "Connecting..."
            @tacnet_status.background = TAC::Palette::TACNET_CONNECTING

            @tacnet_connection_button.value = "Disconnect"
          when :connection_error
            @tacnet_status.value = "Connection Error"
            @tacnet_status.background = TAC::Palette::TACNET_CONNECTION_ERROR

            @tacnet_connection_button.value = "Connect"
          when :not_connected
            @tacnet_status.value = "Not Connected"
            @tacnet_status.background = TAC::Palette::TACNET_NOT_CONNECTED

            @tacnet_connection_button.value = "Connect"
          end
        end
      end

      def update
        super

        @tacnet_status_monitor.update
      end

      def create_group(name)
        window.backend.config.groups << TAC::Config::Group.new(name: name, actions: [])
        window.backend.config_changed!

        populate_groups_list
      end

      def update_group(group, name)
        group.name = name
        window.backend.config_changed!

        populate_groups_list
      end

      def delete_group(group)
        window.backend.config.groups.delete(group)
        window.backend.config_changed!

        @active_group = nil
        @active_group_label.value = ""
        @active_action = nil
        @active_action_label.value = ""
        @actions_list.clear
        @variables_list.clear

        populate_groups_list
      end

      def create_action(name)
        @active_group.actions << TAC::Config::Action.new(name: name, enabled: true, variables: [])
        window.backend.config_changed!

        populate_actions_list(@active_group)
      end

      def update_action(action, name)
        action.name = name
        window.backend.config_changed!

        populate_actions_list(@active_group)
      end

      def delete_action(action)
        @active_group.actions.delete(action)
        window.backend.config_changed!

        @active_action = nil
        @active_action_label.value = ""
        @variables_list.clear

        populate_actions_list(@active_group)
      end

      def create_variable(name, type, value)
        @active_action.variables << TAC::Config::Variable.new(name: name, type: type, value: value)
        window.backend.config_changed!

        populate_variables_list(@active_action)
      end

      def update_variable(variable, name, type, value)
        variable.name = name
        variable.type = type
        variable.value = value

        window.backend.config_changed!

        populate_variables_list(@active_action)
      end

      def delete_variable(variable)
        @active_action.variables.delete(variable)
        window.backend.config_changed!

        populate_variables_list(@active_action)
      end

      def populate_groups_list
        groups = window.backend.config.groups

        @groups_list.clear do
          groups.each_with_index do |group, i|
            flow width: 1.0, **THEME_ITEM_CONTAINER_PADDING do
              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

              button group.name, width: 0.855 do
                @active_group = group
                @active_group_label.value = group.name
                @active_action = nil
                @active_action_label.value = ""

                populate_actions_list(group)
                @variables_list.clear
              end

              button get_image("#{TAC::ROOT_PATH}/media/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Edit group" do
                push_state(Dialog::NamePromptDialog, title: "Rename Group", renaming: group, list: window.backend.config.groups, callback_method: method(:update_group))
              end
              button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete group", **THEME_DANGER_BUTTON do
                push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Delete group and all\nof its actions and variables?", callback_method: proc { delete_group(group) })
              end
            end
          end
        end
      end

      def populate_actions_list(group)
        actions = group.actions

        @actions_list.clear do
          actions.each_with_index do |action, i|
            flow width: 1.0, **THEME_ITEM_CONTAINER_PADDING do
              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

              button action.name, width: 0.8 do
                @active_action = action
                @active_action_label.value = action.name

                populate_variables_list(action)
              end

              toggle_button tip: "Enable action"

              button get_image("#{TAC::ROOT_PATH}/media/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Edit action" do
                push_state(Dialog::NamePromptDialog, title: "Rename Action", renaming: action, list: @active_group.actions, callback_method: method(:update_action))
              end
              button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete action", **THEME_DANGER_BUTTON do
                push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Delete action and all\nof its variables?", callback_method: proc { delete_action(action) })
              end
            end
          end
        end
      end

      def populate_variables_list(action)
        variables = action.variables

        @variables_list.clear do
          variables.each_with_index do |variable, i|
            flow width: 1.0, **THEME_ITEM_CONTAINER_PADDING do
              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

              button "#{variable.name} [Type: #{variable.type}, Value: #{variable.value}]", width: 0.925, tip: "Edit variable" do
                push_state(Dialog::VariableDialog, title: "Edit Variable", variable: variable, callback_method: method(:update_variable))
              end
              button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete variable", **THEME_DANGER_BUTTON do
                push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Delete variable?", callback_method: proc { delete_variable(variable) })
              end
            end
          end
        end
      end

      def refresh_config
        @active_group = nil
        @active_group_label.value = ""
        @active_action = nil
        @active_action_label.value = ""

        @groups_list.clear
        @actions_list.clear
        @variables_list.clear

        populate_groups_list
      end
    end
  end
end