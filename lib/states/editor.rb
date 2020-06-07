module TAC
  class States
    class Editor < CyberarmEngine::GuiState
      def setup
        stack width: 1.0, height: 1.0 do
          stack width: 1.0, height: 0.1 do
            background [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY]

            flow width: 1.0, height: 1.0 do
              stack width: 0.70 do
                label TAC::NAME, color: Gosu::Color::BLACK, bold: true

                flow do
                  [:add, :delete, :clone, :create, :simulate].each do |b|
                    button b.capitalize, text_size: 18
                  end
                end
              end

              flow width: 0.299 do
                stack width: 0.5 do
                  label "TACNET", color: TAC::Palette::TACNET_PRIMARY
                  @tacnet_ip_address = label "192.168.49.1", color: TAC::Palette::TACNET_SECONDARY
                end

                stack width: 0.499 do
                  @tacnet_status = label "Connection Error", background: TAC::Palette::TACNET_CONNECTION_ERROR, text_size: 18, padding: 5, margin_top: 2
                  @tacnet_connection_button = button "Connect", text_size: 18
                end
              end
            end
          end

          flow width: 1.0, height: 0.9 do
            stack width: 0.2, height: 1.0 do
              background TAC::Palette::GROUPS_PRIMARY
              label "Groups"

              @groups_list = stack width: 1.0 do
                TAC::Storage.groups.each_with_index do |group, i|
                  button group.name, width: 1.0, text_size: 18 do
                    populate_actions_list(group.id)
                  end
                end
              end
            end
            stack width: 0.2, height: 1.0 do
              background TAC::Palette::ACTIONS_PRIMARY
              label "Actions"

              @actions_list = stack width: 1.0 do
              end
            end
            stack width: 0.2, height: 1.0 do
              background TAC::Palette::VALUES_PRIMARY
              label "Values"

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
      end

      def populate_actions_list(group_id)
        actions = TAC::Storage.actions(group_id)

        @actions_list.clear do
          actions.each do |action|
            button action.name, text_size: 18, width: 1.0 do
              populate_values_list(action.id)
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