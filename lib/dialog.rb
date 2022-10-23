module TAC
  class Dialog < CyberarmEngine::GuiState
    def setup
      theme(THEME)
      background Gosu::Color.new(0xaa_000000)

      @title = @options[:title] ? @options[:title] : "#{self.class}"

      @dialog_root = stack(width: 0.25, h_align: :center, v_align: :center, border_thickness: 2, border_color: [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY]) do
        # Title bar
        @titlebar = flow(width: 1.0, height: 36) do
          background [TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_SECONDARY]

          label @title, text_size: THEME_SUBHEADING_TEXT_SIZE, font: TAC::THEME_BOLD_FONT, fill: true, text_align: :center, text_border: true, text_border_color: 0xaa_222222, text_border_size: 1

          button get_image("#{TAC::ROOT_PATH}/media/icons/cross.png"), image_height: 1.0, **THEME_DANGER_BUTTON do
            close
          end
        end

        # Dialog body
        @dialog_content = stack(width: 1.0, scroll: true) do
        end
      end

      @dialog_content.clear do
        build
      end
    end

    def build
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
        if child.visible? && child.enabled? &&
           child.is_a?(CyberarmEngine::Element::EditLine) ||
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
      previous_state&.draw
      Gosu.flush

      super
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
      pop_state
    end
  end
end
