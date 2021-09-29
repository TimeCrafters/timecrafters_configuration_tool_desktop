module TAC
  class PracticeGameClock
    module Palette
      TACNET_CONNECTED = Gosu::Color.new(0xff_008000)
      TACNET_CONNECTING = Gosu::Color.new(0xff_ff8800)
      TACNET_CONNECTION_ERROR = Gosu::Color.new(0xff_800000)
      TACNET_NOT_CONNECTED = Gosu::Color.new(0xff_222222)

      TIMECRAFTERS_PRIMARY = Gosu::Color.new(0xff_008000)
      TIMECRAFTERS_SECONDARY = Gosu::Color.new(0xff_006000)
      TIMECRAFTERS_TERTIARY = Gosu::Color.new(0xff_00d000)

      BLUE_ALLIANCE = Gosu::Color.new(0xff_000080)
      RED_ALLIANCE = Gosu::Color.new(0xff_800000)

      TACNET_PRIMARY = Gosu::Color.new(0xff000080)
      TACNET_SECONDARY = Gosu::Color.new(0xff000060)

      GROUPS_PRIMARY = Gosu::Color.new(0xff_444444)
      GROUPS_SECONDARY = Gosu::Color.new(0xff_444444)

      ACTIONS_PRIMARY = Gosu::Color.new(0xff_4444aa)
      ACTIONS_SECONDARY = Gosu::Color.new(0xff_040404)

      VARIABLES_PRIMARY = Gosu::Color.new(0xff_660066)
      VARIABLES_SECONDARY = Gosu::Color.new(0xff_440044)

      EDITOR_PRIMARY = Gosu::Color.new(0xff_446688)
      EDITOR_SECONDARY = Gosu::Color.new(0xff_224466)

      ALERT = TACNET_CONNECTING
    end

    THEME = {
      TextBlock: {
        font: "Canterell",
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
        checkmark_image: "#{File.expand_path("..", __dir__)}/media/icons/checkmark.png",
      },
    }

    DANGEROUS_BUTTON = {
        background: 0xff_800000,
        border_thickness: 1,
        border_color: Gosu::Color.new(0xff_111111),
        hover: {
          background: 0xff_600000,
        },
        active: {
          background: 0xff_f00000,
        }
    }
  end
end
