module TAC
  class Dialog < CyberarmEngine::GuiState
    def setup
      theme(THEME)
      background Gosu::Color.new(0xaa_000000)

      @title = @options[:title] ? @options[:title] : "#{self.class}"
      @window_width, @window_height = window.width, window.height
      @previous_state = window.previous_state

      @dialog_root = stack width: 0.25, border_thickness: 2, border_color: [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY] do
        # Title bar
        @titlebar = flow width: 1.0 do
          background [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY]

          # title
          flow width: 0.9 do
            label @title, text_size: THEME_SUBHEADING_TEXT_SIZE, width: 1.0, text_align: :center, text_shadow: true, text_shadow_color: 0xff_222222, text_shadow_size: 1
          end

          # Buttons
          flow width: 0.0999 do
            button get_image("#{TAC::ROOT_PATH}/media/icons/cross.png"), image_width: 1.0, **THEME_DANGER_BUTTON do
              close
            end
          end
        end

        # Dialog body
        @dialog_content = stack width: 1.0 do
        end
      end

      @dialog_content.clear do
        build
      end

      @root_container.recalculate
      @root_container.recalculate
      @root_container.recalculate

      center_dialog
    end

    def build
    end

    def center_dialog
      @dialog_root.style.x = window.width / 2 - @dialog_root.width / 2
      @dialog_root.style.y = window.height / 2 - @dialog_root.height / 2
    end

    def name_filter(text)
      text.match(/[A-Za-z0-9._\- ]/) ? text : ""
    end

    def try_commit
    end

    def focus_next_element
      elements = []

      _deep_dive_interactive_elements(@dialog_content, elements)

      element_index = elements.find_index(self.focused)

      if element_index && elements.size.positive?
        element = elements[element_index + 1]
        element ||= elements.first

        if element
          request_focus(element)
        end
      end
    end

    def _deep_dive_interactive_elements(element, list)
      element.children.each do |child|
        if child.visible? && child.is_a?(CyberarmEngine::Element::EditLine) ||
          child.is_a?(CyberarmEngine::Element::EditBox) ||
          child.is_a?(CyberarmEngine::Element::CheckBox) ||
          child.is_a?(CyberarmEngine::Element::ToggleButton) ||
          child.is_a?(CyberarmEngine::Element::ListBox)

          list << child
        elsif child.visible? && child.is_a?(CyberarmEngine::Element::Container)
          _deep_dive_interactive_elements(child, list)
        end
      end
    end

    def draw
      @previous_state.draw
      Gosu.flush

      super
    end

    def update
      super

      if window.width != @window_width or window.height != @window_height
        request_recalculate

        @window_width, @window_height = window.width, window.height
      end

      center_dialog
    end

    def button_down(id)
      super

      case id
      when Gosu::KB_ENTER, Gosu::KB_RETURN
        try_commit
      when Gosu::KB_ESCAPE
        close
      when Gosu::KB_TAB
        focus_next_element
      end
    end

    def close
      $window.pop_state
    end
  end
end