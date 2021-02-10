module TAC
  class Pages
    class Presets < Page
      def setup
        header_bar("Manage Presets")

        status_bar.clear do
          tagline "Group Presets", width: 0.495
          tagline "Action Presets", width: 0.495
        end

        body.clear do
          flow(width: 1.0, height: 1.0) do
            @group_presets = stack(width: 0.49995, height: 1.0, scroll: true, border_thickness_right: 1, border_color: [0, Gosu::Color::BLACK, 0, 0]) do
            end

            @action_presets = stack(width: 0.49995, height: 1.0, scroll: true) do
            end
          end
        end

        populate_group_presets
        populate_action_presets
      end

      def populate_group_presets
        @group_presets.clear do
          window.backend.config.presets.groups.each_with_index do |group, i|
            flow(width: 1.0, **THEME_ITEM_CONTAINER_PADDING) do
              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

              button group.name, width: 0.895

              button get_image("#{TAC::ROOT_PATH}/media/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Edit group preset" do
                push_state(
                  Dialog::NamePromptDialog,
                  title: "Rename Group Preset",
                  renaming: group,
                  list: window.backend.config.presets.groups,
                  callback_method: method(:update_group_preset)
                )
              end

              button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete group preset", **THEME_DANGER_BUTTON do
                push_state(
                  Dialog::ConfirmDialog,
                  title: "Are you sure?",
                  message: "Delete group preset and all of its actions and variables?",
                  callback_method: proc { delete_group_preset(group) }
                )
              end
            end
          end
        end
      end

      def populate_action_presets
        @action_presets.clear do
          window.backend.config.presets.actions.each_with_index do |action, i|
            flow(width: 1.0, **THEME_ITEM_CONTAINER_PADDING) do
              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

              button action.name, width: 0.895

              button get_image("#{TAC::ROOT_PATH}/media/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Edit action preset" do
                push_state(
                  Dialog::NamePromptDialog,
                  title: "Rename Action Preset",
                  renaming: action,
                  list: window.backend.config.presets.actions,
                  callback_method: method(:update_action_preset)
                )
              end

              button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete action preset", **THEME_DANGER_BUTTON do
                push_state(
                  Dialog::ConfirmDialog,
                  title: "Are you sure?",
                  message: "Delete action preset and all of its actions and variables?",
                  callback_method: proc { delete_action_preset(action) }
                )
              end
            end
          end
        end
      end

      def update_group_preset(group, name)
        group.name = name
        window.backend.config_changed!

        populate_group_presets
      end

      def delete_group_preset(group)
        window.backend.config.presets.groups.delete(group)
        window.backend.config_changed!

        populate_group_presets
      end

      def update_action_preset(action, name)
        action.name = name
        window.backend.config_changed!

        populate_group_presets
      end

      def delete_action_preset(action)
        window.backend.config.presets.action.delete(action)
        window.backend.config_changed!

        populate_action_presets
      end
    end
  end
end