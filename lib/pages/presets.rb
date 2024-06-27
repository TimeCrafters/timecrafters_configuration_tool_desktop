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

        @scroll_into_view_list = []
        @highlight_item_container = nil
        @highlight_from_color = Gosu::Color.rgba(0, 0, 0, 0)
        @highlight_to_color = Gosu::Color.rgba(THEME_HIGHLIGHTED_COLOR.red, THEME_HIGHLIGHTED_COLOR.green, THEME_HIGHLIGHTED_COLOR.blue, 200)

        @highlight_animator = CyberarmEngine::Animator.new(
          start_time: Gosu.milliseconds - 1,
          duration: 0,
          from: Gosu::Color.rgba(0, 0, 0, 0),
          to: THEME_HIGHLIGHTED_COLOR
        )

        populate_group_presets
        populate_action_presets
      end

      def draw
        super

        unless @highlight_animator.complete?
          item = @highlight_item_container

          Gosu.draw_rect(
            item.x, item.y,
            item.width, item.height,
            @highlight_animator.color_transition,
            item.z + 1
          )
        end
      end

      def update
        super

        current_state.request_repaint unless @highlight_animator.complete?

        while (hash = @scroll_into_view_list.shift)
          list_container = hash[:list]
          item_container = hash[:item]

          return unless list_container
          return unless item_container

          unless (item_container.y + item_container.height).between?(list_container.y, list_container.y + list_container.height)

            list_container.scroll_top = (item_container.y + item_container.height) - (list_container.y + list_container.height)

            list_container.recalculate
          end

          @highlight_item_container = item_container
          @highlight_animator = CyberarmEngine::Animator.new(
            start_time: Gosu.milliseconds,
            duration: 750,
            from: @highlight_from_color,
            to: @highlight_to_color,
            tween: :ease_in_out_back
          )
        end
      end

      def update_list_children(list)
        list.children.sort_by! { |i| i.style.tag.downcase }

        list.children.each_with_index do |child, i|
          child.style.default[:background] = i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

          child.root.gui_state.request_recalculate
        end
      end

      def scroll_into_view(item)
        list_container = nil
        item_container = nil

        if item.is_a?(TAC::Config::Group)
          list_container = @group_presets
        elsif item.is_a?(TAC::Config::Action)
          list_container = @action_presets
        else
          raise "Unsupported item type: #{item.class}"
        end

        item_container = find_element_by_tag(list_container, item.name)

        @scroll_into_view_list << { list: list_container, item: item_container }
      end

      def add_group_container(group)
        index = window.backend.config.presets.groups.index(group)

        flow width: 1.0, height: 36, **THEME_ITEM_CONTAINER_PADDING, tag: group.name do |container|
          background group == @active_group ? THEME_HIGHLIGHTED_COLOR : (index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR)
          @active_group_container = container if group == @active_group

          button group.name, fill: true, text_size: THEME_ICON_SIZE - 3, tag: "label" do
            page(TAC::Pages::Editor, { group: group, group_is_preset: true })
          end

          button get_image("#{TAC::MEDIA_PATH}/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Edit group" do
            push_state(
              Dialog::NamePromptDialog,
              title: "Rename Group Preset",
              renaming: group,
              list: window.backend.config.presets.groups,
              callback_method: method(:update_group_preset)
            )
          end

          button get_image("#{TAC::MEDIA_PATH}/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete group", **THEME_DANGER_BUTTON do
            push_state(
              Dialog::ConfirmDialog,
              title: "Are you sure?",
              message: "Delete group preset and all of its actions and variables?",
              callback_method: proc { delete_group_preset(group) }
            )
          end
        end
      end

      def add_action_container(action)
        index = window.backend.config.presets.actions.index(action)

        stack width: 1.0, height: action.comment.empty? ? 36 : 72, **THEME_ITEM_CONTAINER_PADDING, tag: action.name do |container|
          background action == @active_action ? THEME_HIGHLIGHTED_COLOR : (index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR)
          @active_action_container = container if action == @active_action

          flow width: 1.0, height: 36 do
            button action.name, fill: true, text_size: THEME_ICON_SIZE - 3, tag: "label" do
              page(TAC::Pages::Editor, { action: action, action_is_preset: true })
            end

            button get_image("#{TAC::MEDIA_PATH}/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Edit action" do
              push_state(
                Dialog::ActionDialog,
                title: "Edit Action Preset",
                action: action,
                list: window.backend.config.presets.actions,
                callback_method: method(:update_action_preset)
              )
            end

            button get_image("#{TAC::MEDIA_PATH}/icons/trashcan.png"), image_width: THEME_ICON_SIZE, tip: "Delete action", **THEME_DANGER_BUTTON do
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

      def populate_group_presets
        @group_presets.clear do
          window.backend.config.presets.groups.each do |group|
            add_group_container(group)
          end
        end
      end

      def populate_action_presets
        @action_presets.clear do
          window.backend.config.presets.actions.each do |action|
            add_action_container(action)
          end
        end
      end

      def update_group_preset(group, name)
        old_name = group.name

        group.name = name
        window.backend.config.presets.groups.sort_by! { |g| g.name.downcase }
        window.backend.config_changed!

        group_container = find_element_by_tag(@group_presets, old_name)
        para = find_element_by_tag(group_container, "label")

        label.value = name

        group_container.style.tag = name

        update_list_children(@group_presets)

        scroll_into_view(group)
      end

      def delete_group_preset(group)
        window.backend.config.presets.groups.delete(group)
        window.backend.config.presets.groups.sort_by! { |g| g.name.downcase }
        window.backend.config_changed!

        # Remove deleted action from list
        container = find_element_by_tag(@group_presets, group.name)
        @group_presets.remove(container)

        update_list_children(@group_presets)
      end

      def update_action_preset(action, name, comment)
        old_name = action.name

        action.name = name
        action.comment = comment
        window.backend.config.presets.actions.sort_by! { |a| a.name.downcase }
        window.backend.config_changed!

        action_container = find_element_by_tag(@action_presets, old_name)
        para = find_element_by_tag(action_container, "label")
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

        action_container.style.tag = name

        update_list_children(@action_presets)

        scroll_into_view(action)
      end

      def delete_action_preset(action)
        window.backend.config.presets.actions.delete(action)
        window.backend.config.presets.actions.sort_by! { |a| a.name.downcase }
        window.backend.config_changed!

        # Remove deleted action from list
        container = find_element_by_tag(@action_presets, action.name)
        @action_presets.remove(container)

        update_list_children(@action_presets)
      end
    end
  end
end
