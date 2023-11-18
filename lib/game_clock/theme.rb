module TAC
  class PracticeGameClock
    THEME = {
      TextBlock: {
        font: "NotoSans-Bold",
        color: Gosu::Color.new(0xee_ffffff)
      },
      Button: {
        image_width: 40,
        text_size: 40,
        background: Palette::TIMECRAFTERS_PRIMARY,
        border_thickness: 1,
        border_color: Gosu::Color.new(0xff_111111),
        hover: {
          background: Palette::TIMECRAFTERS_SECONDARY,
        },
        active: {
          background: Palette::TIMECRAFTERS_TERTIARY,
        }
      },
      EditLine: {
        caret_color: Gosu::Color.new(0xff_88ef90),
      },
      ToggleButton: {
        width: 18,
        checkmark_image: "#{MEDIA_PATH}/icons/checkmark.png",
      }
    }
  end
end
