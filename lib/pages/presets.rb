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
            @group_presets = stack(fill: true, height: 1.0, scroll: true, padding_left: 2, padding_top: 2, padding_right: 2, border_thickness_right: 1, border_color: Gosu::Color::BLACK) do
            end

            @action_presets = stack(fill: true, height: 1.0, scroll: true, padding_left: 2, padding_top: 2, padding_right: 2) do
            end
          end
        end

        populate_group_presets
        populate_action_presets
      end

      def populate_group_presets
        @group_presets.clear do
          window.backend.config.presets.groups.each_with_index do |group, i|
            flow(width: 1.0, height: 36, **THEME_ITEM_CONTAINER_PADDING) do
              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

              button group.name, fill: true, text_size: THEME_ICON_SIZE - 3 do
                page(TAC::Pages::Editor, { group: group, group_is_preset: true })
              end

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
            stack(width: 1.0, height: action.comment.empty? ? 36 : 72, **THEME_ITEM_CONTAINER_PADDING) do
              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

              flow(width: 1.0, height: 36) do
                button action.name, fill: true, text_size: THEME_ICON_SIZE - 3 do
                  page(TAC::Pages::Editor, { action: action, action_is_preset: true })
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Edit action preset" do
                  push_state(
                    Dialog::ActionDialog,
                    title: "Edit Action Preset",
                    action: action,
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

              stack(width: 1.0, fill: true, scroll: true, visible: !action.comment.empty?, tag: "comment_container") do
                caption action.comment.to_s, width: 1.0, text_wrap: :word_wrap, text_border: true, text_border_size: 1, text_border_color: 0xaa_000000, tag: "comment"
              end
            end
          end
        end
      end

      def update_group_preset(group, name)
        group.name = name
        window.backend.config.presets.groups.sort_by! { |g| g.name.downcase }
        window.backend.config_changed!

        populate_group_presets
      end

      def delete_group_preset(group)
        window.backend.config.presets.groups.delete(group)
        window.backend.config.presets.groups.sort_by! { |g| g.name.downcase }
        window.backend.config_changed!

        populate_group_presets
      end

      def update_action_preset(action, name, comment)
        action.name = name
        action.comment = comment
        window.backend.config.presets.actions.sort_by! { |a| a.name.downcase }
        window.backend.config_changed!

        populate_action_presets
      end

      def delete_action_preset(action)
        window.backend.config.presets.actions.delete(action)
        window.backend.config.presets.actions.sort_by! { |a| a.name.downcase }
        window.backend.config_changed!

        populate_action_presets
      end
    end
  end
end
