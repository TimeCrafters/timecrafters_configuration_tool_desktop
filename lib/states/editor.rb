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
              stack width: 0.70 do
                label TAC::NAME, color: Gosu::Color.rgb(59, 200, 81), bold: true, text_size: 72
              end

              flow width: 0.299 do
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
            stack width: 0.2, height: 1.0 do
              background TAC::Palette::GROUPS_PRIMARY
              flow do
                label "Groups"
                button "Add Group", text_size: 18 do
                  push_state(TAC::Dialog::NamePromptDialog, title: "Create Group", submit_label: "Add", callback_method: method(:create_group))
                end
              end

              @groups_list = stack width: 1.0 do
              end
            end
            stack width: 0.2, height: 1.0 do
              background TAC::Palette::ACTIONS_PRIMARY
              flow do
                label "Actions"
                button "Add Action", text_size: 18 do
                  if @active_group
                    push_state(TAC::Dialog::NamePromptDialog, title: "Create Action", submit_label: "Add", callback_method: method(:create_action))
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create action,\nno group selected.")
                  end
                end
              end

              @actions_list = stack width: 1.0 do
              end
            end
            stack width: 0.2, height: 1.0 do
              background TAC::Palette::VALUES_PRIMARY
              flow do
                label "Values"
                button "Add Value", text_size: 18 do
                  if @active_action
                    push_state(TAC::Dialog::NamePromptDialog, title: "Create Value", subtitle: "Add Value", submit_label: "Add", callback_method: method(:create_value))
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create value,\nno action selected.")
                  end
                end
              end

              @values_list = stack width: 1.0 do
              end
            end
            stack width: 0.399, height: 1.0 do
              background TAC::Palette::EDITOR_PRIMARY
              label "Editor"

              @editor = stack width: 1.0 do
              end
            end
          end
        end

        populate_groups_list
      end

      def create_group(name)
        window.backend.config[:data][:groups] << {id: rand(100), name: name}
        window.backend.save_config

        populate_groups_list
      end

      def create_action(name)
        window.backend.config[:data][:actions] << {id: rand(100), group_id: @active_group.id, name: name, enabled: true}
        window.backend.save_config

        populate_actions_list(@active_group.id)
      end

      def create_value(name, type = :float, value = 45.0)
        window.backend.config[:data][:values] << {id: rand(100), action_id: @active_action.id, name: name, type: type, value: value}
        window.backend.save_config

        populate_values_list(@active_action.id)
      end

      def populate_groups_list
        groups = TAC::Storage.groups

        @groups_list.clear do
          groups.each do |group|
            button group.name, text_size: 18, width: 1.0 do
              @active_group = group
              @active_action = nil

              populate_actions_list(group.id)
              @values_list.clear
              @editor.clear
            end
          end
        end
      end

      def populate_actions_list(group_id)
        actions = TAC::Storage.actions(group_id)

        @actions_list.clear do
          actions.each do |action|
            button action.name, text_size: 18, width: 1.0 do
              @active_action = action

              populate_values_list(action.id)
              @editor.clear
            end
          end
        end
      end

      def populate_values_list(action_id)
        values = TAC::Storage.values(action_id)

        @values_list.clear do
          values.each do |value|
            button value.name, text_size: 18, width: 1.0 do
              populate_editor(value)
            end
          end
        end
      end

      def populate_editor(value)
        @editor.clear do
          [:id, :action_id, :name, :type, :value].each do |m|
            label "#{m}: #{value.send(m)}", text_size: 18
          end

          case value.type
          when :double, :float, :integer, :string
            edit_line "#{value.value}", width: 1.0
          when :boolean
            toggle_button checked: value.value
          else
            label "Unsupported value type: #{value.type.inspect}", text_size: 18
          end
        end
      end
    end
  end
end