module TAC
  THEME = {
            Label: {
              font: "#{TAC::ROOT_PATH}/media/DejaVuSansCondensed.ttf",
              text_size: 28
            },
            Button: {
              background: TAC::Palette::TIMECRAFTERS_PRIMARY,
              border_thickness: 1,
              border_color: Gosu::Color.new(0xff_111111),
              hover: {
                background: TAC::Palette::TIMECRAFTERS_SECONDARY,
              },
              active: {
                background: TAC::Palette::TIMECRAFTERS_TERTIARY
              }
            }
          }
end