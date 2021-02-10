module TAC
  class Pages
    class Editor < Page
      def setup
        header_bar("Editor")
        @active_group = nil
        @active_action = nil

        menu_bar.clear do
          if @options[:group_is_preset]
            title "Editing group preset: #{@options[:group].name}"
          elsif @options[:action_is_preset]
            title "Editing action preset: #{@options[:action].name}"
          else
            title "Editing configuration: #{window.backend.config.name}"
          end
        end

        status_bar.clear do
          flow(width: 0.3333) do
            label "Active group:", margin_right: 20
            @active_group_label = label ""
          end

          flow(width: 0.3333) do
            label "Active action:", margin_right: 20
            @active_action_label = label ""
          end
        end

        body.clear do
          flow(width: 1.0, height: 1.0) do
            stack width: 0.33333, height: 1.0, border_thickness_right: 1, border_color: [0, Gosu::Color::BLACK, 0, 0] do
              @groups_menu = flow(width: 1.0) do
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
                    push_state(Dialog::NamePromptDialog, title: "Save Group Preset", renaming: @active_group, accept_label: "Save", list: window.backend.config.presets.groups, callback_method: proc { |group, name|
                      clone = TAC::Config::Group.from_json( JSON.parse( @active_group.to_json, symbolize_names: true ))
                      clone.name = "#{name}"
                      window.backend.config.presets.groups << clone
                      window.backend.config_changed!

                      window.toast("Saved Group Preset", "Saved preset: #{name}")
                    })
                  end
                end
              end

              @groups_list = stack width: 1.0, scroll: true do
              end
            end

            stack width: 0.33333, height: 1.0, border_thickness_right: 1, border_color: [0, Gosu::Color::BLACK, 0, 0] do
              @actions_menu = flow(width: 1.0) do
                label "Actions", text_size: THEME_SUBHEADING_TEXT_SIZE

                button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: THEME_ICON_SIZE, tip: "Add action" do
                  if @active_group
                    push_state(TAC::Dialog::ActionDialog, title: "Create Action", list: @active_group.actions, callback_method: method(:create_action))
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create action,\nno group selected.")
                  end
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/button2.png"), image_width: THEME_ICON_SIZE, tip: "Clone currently selected action" do
                  if @active_group && @active_action
                    push_state(Dialog::ActionDialog, title: "Clone Action", action: @active_action, accept_label: "Clone", list: @active_group.actions, callback_method: proc { |action, name, comment|
                      clone = TAC::Config::Action.from_json( JSON.parse( @active_action.to_json, symbolize_names: true ))
                      clone.name    = name
                      clone.comment = comment
                      @active_group.actions << clone
                      window.backend.config_changed!

                      populate_actions_list(@active_group)
                    })
                  end
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/save.png"), image_width: THEME_ICON_SIZE, tip: "Save action as preset" do
                  if @active_action
                    push_state(Dialog::NamePromptDialog, title: "Save Action Preset", renaming: @active_action, accept_label: "Save", list: window.backend.config.presets.actions, callback_method: proc { |action, name|
                      clone = TAC::Config::Action.from_json( JSON.parse( @active_action.to_json, symbolize_names: true ))
                      clone.name = "#{name}"
                      window.backend.config.presets.actions << clone
                      window.backend.config_changed!

                      window.toast("Saved Action Preset", "Saved preset: #{name}")
                    })
                  end
                end
              end

              @actions_list = stack width: 1.0, scroll: true do
              end
            end

            stack width: 0.331, height: 1.0 do
              @variables_menu = flow(width: 1.0) do
                label "Variables", text_size: THEME_SUBHEADING_TEXT_SIZE
                button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: THEME_ICON_SIZE, tip: "Add variable" do
                  if @active_action
                    push_state(TAC::Dialog::VariableDialog, title: "Create Variable", callback_method: method(:create_variable))
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create variable,\nno action selected.")
                  end
                end
              end

              @variables_list = stack width: 1.0, scroll: true do
              end
            end
          end
        end

        populate_groups_list

        if @options[:group]
          @active_group = @options[:group]
          @active_group_label.value = @active_group.name

          populate_actions_list(@active_group)

          if @options[:action]
            @active_action = @options[:action]
            @active_action_label.value = @active_action.name

            populate_variables_list(@active_action)

            if @options[:variable]
              # Scroll into view?
            end
          end
        end

        body.root.subscribe(:window_size_changed) do
          set_list_heights
        end
      end

      def set_list_heights
        @groups_list.style.height = body.height - @groups_menu.height
        @actions_list.style.height = body.height - @actions_menu.height
        @variables_list.style.height = body.height - @variables_menu.height
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

      def create_action(name, comment)
        @active_group.actions << TAC::Config::Action.new(name: name, comment: comment, enabled: true, variables: [])
        window.backend.config_changed!

        populate_actions_list(@active_group)
      end

      def update_action(action, name, comment)
        action.name = name
        action.comment = comment
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

              button group.name, width: 0.8 do
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

        set_list_heights
      end

      def populate_actions_list(group)
        actions = group.actions

        @actions_list.clear do
          actions.each_with_index do |action, i|
            stack width: 1.0, **THEME_ITEM_CONTAINER_PADDING do
              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

              flow width: 1.0 do
                button action.name, width: 0.72 do
                  @active_action = action
                  @active_action_label.value = action.name

                  populate_variables_list(action)
                end

                action_enabled_toggle = toggle_button tip: "Enable action", checked: action.enabled
                action_enabled_toggle.subscribe(:changed) do |sender, value|
                  action.enabled = value
                  window.backend.config_changed!
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Edit action" do
                  push_state(Dialog::ActionDialog, title: "Rename Action", action: action, list: @active_group.actions, callback_method: method(:update_action))
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete action", **THEME_DANGER_BUTTON do
                  push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Delete action and all\nof its variables?", callback_method: proc { delete_action(action) })
                end
              end

              caption "#{action.comment}", width: 1.0, text_wrap: :word_wrap unless action.comment.empty?
            end
          end
        end

        set_list_heights
      end

      def populate_variables_list(action)
        variables = action.variables

        @variables_list.clear do
          variables.each_with_index do |variable, i|
            stack width: 1.0, **THEME_ITEM_CONTAINER_PADDING do
              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

              flow(width: 1.0) do
                button "#{variable.name}", width: 0.89, tip: "Edit variable" do
                  push_state(Dialog::VariableDialog, title: "Edit Variable", variable: variable, callback_method: method(:update_variable))
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete variable", **THEME_DANGER_BUTTON do
                  push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Delete variable?", callback_method: proc { delete_variable(variable) })
                end
              end

              caption "Type: #{variable.type}"
              caption "Value: #{variable.value}"
            end
          end
        end

        set_list_heights
      end
    end
  end
end