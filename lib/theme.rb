module TAC
  THEME = {
    Label: {
      font: "#{TAC::ROOT_PATH}/media/fonts/DejaVuSansCondensed.ttf",
      text_size: 18,
      color: Gosu::Color.new(0xee_ffffff),
    },
    Button: {
      background: TAC::Palette::TIMECRAFTERS_PRIMARY,
      border_thickness: 1,
      border_color: Gosu::Color.new(0xff_111111),
      hover: {
        background: TAC::Palette::TIMECRAFTERS_SECONDARY,
      },
      active: {
        background: TAC::Palette::TIMECRAFTERS_TERTIARY,
      }
    },
    EditLine: {
      caret_color: Gosu::Color.new(0xff_434343),
    },
    ToggleButton: {
      width: 18,
      checkmark_image: "#{TAC::ROOT_PATH}/media/icons/checkmark.png",
    },
  }

  THEME_DANGER_BUTTON = {
    color: Gosu::Color.new(0xff_ffffff),
    background: Gosu::Color.new(0xff_800000),
    hover: {
      background: Gosu::Color.new(0xff_600000),
    },
    active: {
      background: Gosu::Color.new(0xff_c00000),
    }
  }

  THEME_ICON_SIZE = 18
  THEME_HEADING_TEXT_SIZE = 32
  THEME_SUBHEADING_TEXT_SIZE = 28
  THEME_ITEM_PADDING = 8
  THEME_EVEN_COLOR = Gosu::Color.new(0xff_606060)
  THEME_ODD_COLOR = Gosu::Color.new(0xff_202020)
  THEME_CONTENT_BACKGROUND = Gosu::Color.new(0x88_007f3f)
  THEME_HEADER_BACKGROUND = [
    TAC::Palette::TIMECRAFTERS_PRIMARY, TAC::Palette::TIMECRAFTERS_PRIMARY,
    TAC::Palette::TIMECRAFTERS_SECONDARY, TAC::Palette::TIMECRAFTERS_SECONDARY,
  ]
end