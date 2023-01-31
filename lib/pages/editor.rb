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
            stack fill: true, height: 1.0, padding_left: 2, padding_right: 2, border_thickness_right: 1, border_color: Gosu::Color::BLACK do
              @groups_menu = flow(width: 1.0, height: 36) do
                label "Groups", text_size: THEME_SUBHEADING_TEXT_SIZE, fill: true, text_align: :center

                button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: THEME_ICON_SIZE, tip: "Add group" do
                  push_state(TAC::Dialog::NamePromptDialog, title: "Create Group", list: window.backend.config.groups, callback_method: method(:create_group))
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/button2.png"), image_width: THEME_ICON_SIZE, tip: "Clone currently selected group" do
                  if @active_group
                    push_state(Dialog::NamePromptDialog, title: "Clone Group", renaming: @active_group, accept_label: "Clone", list: window.backend.config.groups, callback_method: proc { |group, name|
                      clone = TAC::Config::Group.from_json( JSON.parse( @active_group.to_json, symbolize_names: true ))
                      clone.name = name.to_s

                      window.backend.config.groups << clone
                      window.backend.config_changed!

                      populate_groups_list
                    })
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to clone group, no group selected.")
                  end
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/save.png"), image_width: THEME_ICON_SIZE, tip: "Save group as preset" do
                  if @active_group
                    push_state(Dialog::NamePromptDialog, title: "Save Group Preset", renaming: @active_group, accept_label: "Save", list: window.backend.config.presets.groups, callback_method: proc { |group, name|
                      clone = TAC::Config::Group.from_json( JSON.parse( @active_group.to_json, symbolize_names: true ))
                      clone.name = name.to_s

                      window.backend.config.presets.groups << clone
                      window.backend.config.presets.groups.sort_by! { |g| g.name.downcase }
                      window.backend.config_changed!

                      window.toast("Saved Group Preset", "Saved preset: #{name}")
                    })
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create group preset, no group selected.")
                  end
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/import.png"), image_width: THEME_ICON_SIZE, tip: "Import group from preset" do
                  push_state(Dialog::PickPresetDialog, title: "Pick Group Preset", limit: :groups, callback_method: proc { |preset|
                    push_state(Dialog::NamePromptDialog, title: "Name Group", renaming: preset, accept_label: "Add", list: window.backend.config.groups, callback_method: proc { |group, name|
                      clone = TAC::Config::Group.from_json( JSON.parse( group.to_json, symbolize_names: true ))
                      clone.name = name.to_s

                      window.backend.config.groups << clone
                      window.backend.config.groups.sort_by! { |g| g.name.downcase }
                      window.backend.config_changed!

                      populate_groups_list
                    })
                  })
                end
              end

              @groups_list = stack width: 1.0, fill: true, scroll: true do
              end
            end

            stack fill: true, height: 1.0, padding_left: 2, padding_right: 2, border_thickness_right: 1, border_color: Gosu::Color::BLACK do
              @actions_menu = flow(width: 1.0, height: 36) do
                label "Actions", text_size: THEME_SUBHEADING_TEXT_SIZE, fill: true, text_align: :center

                button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: THEME_ICON_SIZE, tip: "Add action" do
                  if @active_group
                    push_state(TAC::Dialog::ActionDialog, title: "Create Action", list: @active_group.actions, callback_method: method(:create_action))
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create action, no group selected.")
                  end
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/button2.png"), image_width: THEME_ICON_SIZE, tip: "Clone currently selected action" do
                  if @active_group && @active_action
                    push_state(Dialog::ActionDialog, title: "Clone Action", action: @active_action, cloning: true, accept_label: "Clone", list: @active_group.actions, callback_method: proc { |action, name, comment|
                      clone = TAC::Config::Action.from_json( JSON.parse( @active_action.to_json, symbolize_names: true ))
                      clone.name    = name
                      clone.comment = comment

                      @active_group.actions << clone
                      window.backend.config_changed!

                      populate_actions_list(@active_group)
                    })
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to clone action, no action selected.")
                  end
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/save.png"), image_width: THEME_ICON_SIZE, tip: "Save action as preset" do
                  if @active_action
                    push_state(Dialog::NamePromptDialog, title: "Save Action Preset", renaming: @active_action, accept_label: "Save", list: window.backend.config.presets.actions, callback_method: proc { |action, name|
                      clone = TAC::Config::Action.from_json( JSON.parse( @active_action.to_json, symbolize_names: true ))
                      clone.name = "#{name}"

                      window.backend.config.presets.actions << clone
                      window.backend.config.presets.actions.sort_by! { |a| a.name.downcase }
                      window.backend.config_changed!

                      window.toast("Saved Action Preset", "Saved preset: #{name}")
                    })
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create action preset, no action selected.")
                  end
                end

                button get_image("#{TAC::ROOT_PATH}/media/icons/import.png"), image_width: THEME_ICON_SIZE, tip: "Import action from preset" do
                  if @active_group
                    push_state(Dialog::PickPresetDialog, title: "Pick Action Preset", limit: :actions, callback_method: proc { |preset|
                      push_state(Dialog::ActionDialog, title: "Name Action", action: preset, accept_label: "Add", list: @active_group.actions, callback_method: proc { |action, name, comment|
                        clone = TAC::Config::Action.from_json( JSON.parse( action.to_json, symbolize_names: true ))
                        clone.name = name.to_s
                        clone.comment = comment.to_s
                        clone.enabled = true

                        @active_group.actions << clone
                        @active_group.actions.sort_by! { |a| a.name.downcase }
                        window.backend.config_changed!

                        populate_actions_list(@active_group)
                      })
                    })
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to import action preset, no group selected.")
                  end
                end
              end

              @actions_list = stack width: 1.0, fill: true, scroll: true do
              end
            end

            stack fill: true, height: 1.0, padding_left: 2, padding_right: 2 do
              @variables_menu = flow(width: 1.0, height: 36) do
                label "Variables", text_size: THEME_SUBHEADING_TEXT_SIZE, fill: true, text_align: :center
                button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: THEME_ICON_SIZE, tip: "Add variable" do
                  if @active_action
                    push_state(TAC::Dialog::VariableDialog, title: "Create Variable", list: @active_action.variables, callback_method: method(:create_variable))
                  else
                    push_state(TAC::Dialog::AlertDialog, title: "Error", message: "Unable to create variable, no action selected.")
                  end
                end
              end

              @variables_list = stack width: 1.0, fill: true, scroll: true do
              end
            end
          end
        end

        populated_groups_list = false

        if @options[:group_is_preset]
          populated_groups_list = true

          @active_group = @options[:group]
          @active_group_label.value = @active_group.name

          populate_groups_list
          populate_actions_list(@active_group)

          @groups_menu.hide

        elsif @options[:action_is_preset]
          @active_action = @options[:action]
          @active_action_label.value = @active_action.name

          populate_variables_list(@options[:action])

          @groups_menu.hide
          @actions_menu.hide

        else
          if @options[:group]
            populated_groups_list = true

            @active_group = @options[:group]
            @active_group_label.value = @active_group.name

            populate_groups_list
            populate_actions_list(@active_group) unless @options[:action]

            if @options[:action]
              @active_action = @options[:action]
              @active_action_label.value = @active_action.name

              populate_actions_list(@active_group)

              populate_variables_list(@active_action)

              if @options[:variable]
                # Scroll into view?
              end
            end
          end
        end

        populate_groups_list unless populated_groups_list
      end

      def create_group(name)
        group = TAC::Config::Group.new(name: name, actions: [])

        window.backend.config.groups << group
        window.backend.config.groups.sort_by! { |g| g.name.downcase }
        window.backend.config_changed!

        populate_groups_list

        scroll_into_view(group)
      end

      def update_group(group, name)
        group.name = name
        window.backend.config.groups.sort_by! { |g| g.name.downcase }
        window.backend.config_changed!

        populate_groups_list

        scroll_into_view(group)
      end

      def delete_group(group)
        window.backend.config.groups.delete(group)
        window.backend.config.groups.sort_by! { |g| g.name.downcase }
        window.backend.config_changed!

        @active_group = nil
        @active_group_container = nil
        @active_group_label.value = ""
        @active_action = nil
        @active_active_container = nil
        @active_action_label.value = ""
        @actions_list.clear
        @variables_list.clear

        populate_groups_list
      end

      def create_action(name, comment)
        action = TAC::Config::Action.new(name: name, comment: comment, enabled: true, variables: [])

        @active_group.actions << action
        @active_group.actions.sort_by! { |a| a.name.downcase }
        window.backend.config_changed!

        @actions_list.append do
          add_action_container(action)
        end

        update_list_children(@actions_list)

        scroll_into_view(action)
      end

      def update_action(action, name, comment)
        old_name = action.name

        action.name = name
        action.comment = comment
        @active_group.actions.sort_by! { |a| a.name.downcase }
        window.backend.config_changed!

        action_container = find_element_by_tag(@actions_list, old_name.downcase)
        label = find_element_by_tag(action_container, "label")
        comment_container = find_element_by_tag(action_container, "comment_container")
        comment_label = find_element_by_tag(action_container, "comment")

        label.value = name
        if comment.empty?
          action_container.style.height = 36
          comment_container.hide
          comment_label.value = ""
        else
          action_container.style.height = 72
          comment_container.show
          comment_label.value = comment.to_s
        end

        update_list_children(@actions_list)

        scroll_into_view(action)
      end

      def delete_action(action)
        @active_group.actions.delete(action)
        @active_group.actions.sort_by! { |a| a.name.downcase }
        window.backend.config_changed!

        @active_action = nil
        @active_action_label.value = ""
        @variables_list.clear

        # Remove deleted action from list
        container = find_element_by_tag(@actions_list, action.name.downcase)
        @actions_list.remove(container)

        update_list_children(@actions_list)
      end

      def create_variable(name, type, value)
        variable = TAC::Config::Variable.new(name: name, type: type, value: value)

        @active_action.variables << variable
        @active_action.variables.sort_by! { |v| v.name.downcase }
        window.backend.config_changed!

        populate_variables_list(@active_action)

        scroll_into_view(variable)
      end

      def update_variable(variable, name, type, value)
        variable.name = name
        variable.type = type
        variable.value = value

        @active_action.variables.sort_by! { |v| v.name.downcase }

        window.backend.config_changed!

        populate_variables_list(@active_action)

        scroll_into_view(variable)
      end

      def delete_variable(variable)
        @active_action.variables.delete(variable)
        @active_action.variables.sort_by! { |v| v.name.downcase }
        window.backend.config_changed!

        populate_variables_list(@active_action)
      end

      def update_list_children(list)
        is_group = list == @groups_list
        is_action = list == @actions_list
        is_variable = list == @variables_list

        list.children.sort_by! { |i| i.style.tag.downcase }

        list.children.each_with_index do |child, i|
          bg_color = i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR
          bg_color = THEME_HIGHLIGHTED_COLOR if is_group && @active_group&.name == child.style.tag
          bg_color = THEME_HIGHLIGHTED_COLOR if is_action && @active_action&.name == child.style.tag

          child.style.default[:background] = bg_color

          child.root.gui_state.request_recalculate
        end
      end

      def scroll_into_view(item)
        if item.is_a?(TAC::Config::Group)
        elsif item.is_a?(TAC::Config::Action)
        elsif item.is_a?(TAC::Config::Variable)
        else
          raise "Unsupported item type: #{item.class}"
        end
      end

      def populate_groups_list
        @groups_list.scroll_top = 0

        groups = []

        unless @options[:group_is_preset] || @options[:action_is_preset]
          groups = window.backend.config.groups
        end

        @groups_list.clear do
          groups.each do |group|
            add_group_container(group)
          end
        end
      end

      def populate_actions_list(group)
        @actions_list.scroll_top = 0

        actions = group.actions

        @actions_list.clear do
          actions.each do |action|
            add_action_container(action)
          end
        end
      end

      def populate_variables_list(action)
        @variables_list.scroll_top = 0

        variables = action.variables

        @variables_list.clear do
          variables.each do |variable|
            add_variable_container(variable)
          end
        end
      end

      def add_group_container(group)
        index = window.backend.config.groups.index(group)

        flow width: 1.0, height: 36, **THEME_ITEM_CONTAINER_PADDING, tag: group.name do |container|
          background group == @active_group ? THEME_HIGHLIGHTED_COLOR : (index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR)
          @active_group_container = container if group == @active_group

          button group.name, fill: true, text_size: THEME_ICON_SIZE - 3, tag: "label" do
            @active_group = group
            @active_group_container = container
            @active_group_label.value = group.name
            @active_action = nil
            @active_action_container = nil
            @active_action_label.value = ""

            update_list_children(@groups_list)

            populate_actions_list(group)
            @variables_list.clear
          end

          button get_image("#{TAC::ROOT_PATH}/media/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Edit group" do
            push_state(Dialog::NamePromptDialog, title: "Rename Group", renaming: group, list: window.backend.config.groups, callback_method: method(:update_group))
          end
          button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete group", **THEME_DANGER_BUTTON do
            push_state(Dialog::ConfirmDialog, dangerous: true, title: "Are you sure?", message: "Delete group and all of its actions and variables?", callback_method: proc { delete_group(group) })
          end
        end
      end

      def add_action_container(action)
        index = @active_group.actions.index(action)

        stack width: 1.0, height: action.comment.empty? ? 36 : 72, **THEME_ITEM_CONTAINER_PADDING, tag: action.name do |container|
          background action == @active_action ? THEME_HIGHLIGHTED_COLOR : (index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR)
          @active_action_container = container if action == @active_action

          flow width: 1.0, height: 36 do
            button action.name, fill: true, text_size: THEME_ICON_SIZE - 3, tag: "label" do
              @active_action = action
              @active_action_container = container
              @active_action_label.value = action.name

              update_list_children(@actions_list)

              populate_variables_list(action)
            end

            action_enabled_toggle = toggle_button tip: "Enable action", checked: action.enabled
            action_enabled_toggle.subscribe(:changed) do |sender, value|
              action.enabled = value
              window.backend.config_changed!
            end

            button get_image("#{TAC::ROOT_PATH}/media/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Edit action" do
              push_state(Dialog::ActionDialog, title: "Edit Action", action: action, list: @active_group.actions, callback_method: method(:update_action))
            end

            button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete action", **THEME_DANGER_BUTTON do
              push_state(Dialog::ConfirmDialog, dangerous: true, title: "Are you sure?", message: "Delete action and all of its variables?", callback_method: proc { delete_action(action) })
            end
          end

          stack(width: 1.0, fill: true, scroll: true, visible: !action.comment.empty?, tag: "comment_container") do
            caption action.comment.to_s, width: 1.0, text_wrap: :word_wrap, text_border: true, text_border_size: 1, text_border_color: 0xaa_000000, tag: "comment"
          end
        end
      end

      def add_variable_container(variable)
        index = @active_action.variables.index(variable)

        stack width: 1.0, height: 96, **THEME_ITEM_CONTAINER_PADDING, tag: variable.name do
          background index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

          flow(width: 1.0, fill: true) do
            button variable.name, fill: true, text_size: THEME_ICON_SIZE - 3, tip: "Edit variable", tag: "label" do
              push_state(Dialog::VariableDialog, title: "Edit Variable", variable: variable, list: @active_action.variables, callback_method: method(:update_variable))
            end

            button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete variable", **THEME_DANGER_BUTTON do
              push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Delete variable?", callback_method: proc { delete_variable(variable) })
            end
          end

          caption "Type: #{variable.type}", tag: "type", fill: true
          caption "Value: #{variable.value}", tag: "value", fill: true
        end
      end

      def button_down(id)
        super

        return if control_down? || shift_down? || !alt_down?

        case id
        when Gosu::KB_G
          push_state(
            TAC::Dialog::NamePromptDialog,
            title: "Create Group",
            list: window.backend.config.groups,
            callback_method: method(:create_group)
          )
        when Gosu::KB_A
          if @active_group
            push_state(
              TAC::Dialog::ActionDialog,
              title: "Create Action",
              list: @active_group.actions,
              callback_method: method(:create_action)
            )
          else
            push_state(
              TAC::Dialog::AlertDialog,
              title: "Error",
              message: "Unable to create action, no group selected."
            )
          end
        when Gosu::KB_V
          if @active_action
            push_state(
              TAC::Dialog::VariableDialog,
              title: "Create Variable",
              list: @active_action.variables,
              callback_method: method(:create_variable)
            )
          else
            push_state(
              TAC::Dialog::AlertDialog,
              title: "Error",
              message: "Unable to create variable, no action selected."
            )
          end
        end
      end
    end
  end
end
