module TAC
  class States
    class Editor < CyberarmEngine::GuiState
      def setup
        @active_group = nil
        @active_action = nil

        theme(THEME)

        stack width: 1.0, height: 1.0 do
          stack width: 1.0, height: 0.1 do
            background [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY]

            flow width: 1.0, height: 1.0 do
              stack width: 0.60 do
                label TAC::NAME, color: Gosu::Color::BLACK, bold: true
                flow width: 1.0 do
                  flow width: 0.3 do
                    label "Group: ", text_size: 18
                    @active_group_label = label "", text_size: 18
                  end

                  flow width: 0.3 do
                    label "Action: ", text_size: 18
                    @active_action_label = label "", text_size: 18
                  end

                  flow width: 0.395 do
                    button "►", text_size: 18, margin_left: 10, tip: "Simulate robot path"
                    button "Presets", text_size: 18, margin_left: 10, tip: "Manage presets" do
                      push_state(ManagePresets)
                    end
                    button "Save", text_size: 18, margin_left: 10, tip: "Save config to disk" do
                      window.backend.save_config
                    end
                    button "▲", text_size: 18, margin_left: 10, tip: "Upload local config to remote, if connected." do
                      window.backend.upload_config
                    end
                    button "▼", text_size: 18, margin_left: 10, tip: "Download remote config, if connected." do
                      push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Replace local config with\n remote config?", callback_method: proc { window.backend.download_config })
                    end
                  end
                end
              end

              flow width: 0.399 do
                stack width: 0.5 do
                  label "TACNET v#{TACNET::Packet::PROTOCOL_VERSION}", color: TAC::Palette::TACNET_PRIMARY
                  @tacnet_ip_address = label "#{TACNET::DEFAULT_HOSTNAME}:#{TACNET::DEFAULT_PORT}", color: TAC::Palette::TACNET_SECONDARY
                end

                stack width: 0.499 do
                  @tacnet_status = label "Connection Error", background: TAC::Palette::TACNET_CONNECTION_ERROR, text_size: 18, padding: 5, margin_top: 2
                  @tacnet_connection_button = button "Connect", text_size: 18 do
                    window.backend.tacnet.connect("localhost")
                  end
                end
              end
            end
          end

          flow width: 1.0, height: 0.9 do
            stack width: 0.333, height: 1.0 do
              background TAC::Palette::GROUPS_PRIMARY
              flow do
                label "Groups"
                button "+", text_size: 18 do
                  push_state(TAC::Dialog::NamePromptDialog, title: "Create Group", callback_method: method(:create_group))
                end
                button "Clone", text_size: 18
                button "Create Preset", text_size: 18
              end

              @groups_list = stack width: 1.0 do
              end
            end
            stack width: 0.333, height: 1.0 do
              background TAC::Palette::ACTIONS_PRIMARY
              flow do
                label "Actions"
                button "+", text_size: 18 do
                  if @active_group
                    push_state(TAC::Dialog::NamePromptDialog, title: "Create Action", callback_method: method(:create_action))
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create action,\nno group selected.")
                  end
                end
                button "Clone", text_size: 18
                button "Create Preset", text_size: 18
              end

              @actions_list = stack width: 1.0 do
              end
            end
            stack width: 0.333, height: 1.0 do
              background TAC::Palette::VALUES_PRIMARY
              flow do
                label "Values"
                button "+", text_size: 18 do
                  if @active_action
                    push_state(TAC::Dialog::VariableDialog, title: "Create Value", callback_method: method(:create_value))
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create value,\nno action selected.")
                  end
                end
              end

              @values_list = stack width: 1.0 do
              end
            end
          end
        end

        populate_groups_list
      end

      def create_group(name)
        window.backend.config[:data][:groups] << {id: rand(100), name: name}
        window.backend.config_changed!

        populate_groups_list
      end

      def update_group(group_struct, name)
        group = window.backend.config[:data][:groups].find { |g| g[:id] == group_struct.id }
        group[:name] = name

        window.backend.config_changed!

        populate_groups_list
      end

      def delete_group(group_struct)
        group = window.backend.config[:data][:groups].find { |a| a[:id] == group_struct.id }
        window.backend.config[:data][:groups].delete(group)

        window.backend.config[:data][:actions].select { |a| a[:group_id] == group[:id] }.each do |action|
          window.backend.config[:data][:actions].delete(action)
          window.backend.config[:data][:values].delete_if { |v| v[:action_id] == action[:id] }
        end
        window.backend.config_changed!

        @active_group = nil
        @active_group_label.value = ""
        @active_action = nil
        @active_action_label.value = ""
        @actions_list.clear
        @values_list.clear

        populate_groups_list
      end

      def create_action(name)
        window.backend.config[:data][:actions] << {id: rand(100), group_id: @active_group.id, name: name, enabled: true}
        window.backend.config_changed!

        populate_actions_list(@active_group.id)
      end

      def update_action(action_struct, name)
        action = window.backend.config[:data][:actions].find { |a| a[:id] == action_struct.id }
        action[:name] = name

        window.backend.config_changed!

        populate_actions_list(@active_group.id)
      end

      def delete_action(action_struct)
        action = window.backend.config[:data][:actions].find { |a| a[:id] == actions_struct.id }
        window.backend.config[:data][:actions].delete(action)
        window.backend.config[:data][:values].delete_if { |v| v[:action_id] == action[:id] }
        window.backend.config_changed!

        @active_action = nil
        @active_action_label.value = ""
        @values_list.clear

        populate_actions_list(@active_group.id)
      end

      def create_value(name, type, value)
        window.backend.config[:data][:values] << {id: rand(100), action_id: @active_action.id, name: name, type: type, value: value}
        window.backend.config_changed!

        populate_values_list(@active_action.id)
      end

      def update_value(value_struct, name, type, value)
        _v = window.backend.config[:data][:values].find { |v| v[:id] == value_struct.id }
        _v[:name] = name
        _v[:type] = type
        _v[:value] = value

        window.backend.config_changed!

        populate_values_list(@active_action.id)
      end

      def delete_value(value_struct)
        _v = window.backend.config[:data][:values].find { |v| v[:id] == value_struct.id }
        window.backend.config[:data][:values].delete(_v)
        window.backend.config_changed!

        populate_values_list(@active_action.id)
      end

      def populate_groups_list
        groups = TAC::Storage.groups

        @groups_list.clear do
          groups.each do |group|
            flow width: 1.0 do
              button group.name, text_size: 18, width: 0.855 do
                @active_group = group
                @active_group_label.value = group.name
                @active_action = nil
                @active_action_label.value = ""

                populate_actions_list(group.id)
                @values_list.clear
              end

              button "E", text_size: 18 do
                push_state(Dialog::NamePromptDialog, title: "Rename Group", renaming: group, callback_method: method(:update_group))
              end
              button "D", text_size: 18 do
                push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Delete group and all\nof its actions and values?", callback_method: proc { delete_group(group) })
              end
            end
          end
        end
      end

      def populate_actions_list(group_id)
        actions = TAC::Storage.actions(group_id)

        @actions_list.clear do
          actions.each do |action|
            flow width: 1.0 do
              button action.name, text_size: 18, width: 0.855 do
                @active_action = action
                @active_action_label.value = action.name

                populate_values_list(action.id)
              end

              button "E", text_size: 18 do
                push_state(Dialog::NamePromptDialog, title: "Rename Action", renaming: action, callback_method: method(:update_action))
              end
              button "D", text_size: 18 do
                push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Delete action and all\nof its values?", callback_method: proc { delete_action(action) })
              end
            end
          end
        end
      end

      def populate_values_list(action_id)
        values = TAC::Storage.values(action_id)

        @values_list.clear do
          values.each_with_index do |value, i|
            flow width: 1.0 do
              background TAC::Palette::VALUES_SECONDARY if i.odd?

              label value.name, text_size: 18, width: 0.855

              button "E", text_size: 18 do
                push_state(Dialog::VariableDialog, title: "Edit Variable", value: value, callback_method: method(:update_value))
              end
              button "D", text_size: 18 do
                push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Delete value?", callback_method: proc { delete_value(value) })
              end
            end
          end
        end
      end
    end
  end
end