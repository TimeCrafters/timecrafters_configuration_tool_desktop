class Editor < CyberarmEngine::GuiState
  include CyberarmEngine::Theme # get access to deep_merge method
  attr_reader :header_bar, :header_bar_label, :navigation, :content, :menu_bar, :status_bar, :body

  def setup
    window.show_cursor = true

    @window_width = 0
    @window_height = 0

    @last_tacnet_status = nil

    @pages = {}
    @page = nil

    # TODO: Use these colors for buttons
    _theme = {
      Button: {
        background: 0xff_006000,
        border_color: 0x88_111111,
        hover: {
          color: 0xff_ffffff,
          background: 0xff_00d000,
          border_color: 0x88_111111
        },
        active: {
          color: 0xff_ffffff,
          background: 0xff_004000,
          border_color: 0x88_111111
        }
      }
    }

    theme(deep_merge(TAC::THEME, _theme))

    @header_bar = flow(width: 1.0, height: 36) do
      background 0xff_006000

      @header_bar_label = para TAC::NAME, fill: true, text_align: :center, text_size: 32, font: TAC::THEME_BOLD_FONT, margin_left: BORDERLESS ? 36 * 3 : 0

      @window_controls = flow(width: 36 * 3, height: 1.0) do
        button get_image("#{TAC::MEDIA_PATH}/icons/minus.png"), tip: "Minimize", image_height: 1.0 do
          window.minimize if window.respond_to?(:minimize)
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/larger.png"), tip: "Maximize", image_height: 1.0 do |btn|
          window.maximize if window.respond_to?(:maximize)
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/cross.png"), tip: "Exit", image_height: 1.0, **TAC::THEME_DANGER_BUTTON do
          window.close
        end
      end
    end

    @container = flow(width: 1.0, height: 1.0) do
      @navigation = stack(width: 64, height: 1.0, scroll: true) do
        background 0xff_333333

        button get_image("#{TAC::MEDIA_PATH}/icons/home.png"), margin: 4, tip: "Home", image_width: 1.0 do
          page(TAC::Pages::Home)
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/menuList.png"), margin: 4, tip: "Editor", image_width: 1.0 do
          page(TAC::Pages::EditorV3)
        end

        @tacnet_button = button get_image("#{TAC::MEDIA_PATH}/icons/signal3.png"), margin: 4, tip: "TACNET", image_width: 1.0 do
          page(TAC::Pages::TACNET)
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/gear.png"), margin: 4, tip: "Configurations", image_width: 1.0 do
          page(TAC::Pages::Configurations)
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/menuGrid.png"), margin: 4, tip: "Presets", image_width: 1.0 do
          page(TAC::Pages::Presets)
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/zoom.png"), margin: 4, tip: "Search", image_width: 1.0 do
          page(TAC::Pages::Search)
        end

        stack(margin_left: 4, width: 1.0, margin_right: 4) do
          background 0xff_444444
          para "Tools", width: 1.0, text_align: :center
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/right.png"), margin: 4, tip: "Simulator", image_width: 1.0 do
          page(TAC::Pages::Simulator)
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/joystickLeft.png"), margin: 4, tip: "Field Planner", image_width: 1.0 do
          page(TAC::Pages::FieldPlanner)
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/massiveMultiplayer.png"), margin: 4, tip: "Drive Team Rotation Generator", image_width: 1.0 do
          page(TAC::Pages::DriveTeamRotationGenerator)
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/custom_stopWatch.png"), margin: 4, tip: "Game Clock", image_width: 1.0 do
          page(TAC::Pages::GameClock)
        end

        button get_image("#{TAC::MEDIA_PATH}/icons/power.png"), margin: 4, tip: "Exit", image_width: 1.0, **TAC::THEME_DANGER_BUTTON do
          window.close
        end
      end

      @content = stack(fill: true, height: 1.0) do
        @chrome = stack(width: 1.0, height: 96) do
          @menu_bar = flow(width: 1.0, height: 48, padding: 8) do
            background 0xff_008000
          end

          @status_bar = flow(width: 1.0, height: 96 - 48, padding: 2) do
            background 0xff_006000
          end
        end

        @body = stack(width: 1.0, height: 1.0) do
          background 0xff_707070
        end
      end
    end

    @window_controls.hide unless BORDERLESS

    page(TAC::Pages::Home)
  end

  def draw
    @page&.draw

    super
  end

  def update
    super

    @page.update if @page

    if @last_tacnet_status != window.backend.tacnet.status
      @last_tacnet_status = window.backend.tacnet.status

      case window.backend.tacnet.status
      when :not_connected
        @tacnet_button.style.color = Gosu::Color::WHITE
        @header_bar.style.background = 0xff_006000
      when :connected
        @tacnet_button.style.color = Gosu::Color::WHITE
        @header_bar.style.background = TAC::Palette::TACNET_PRIMARY
      when :connecting
        @tacnet_button.style.color = TAC::Palette::TACNET_CONNECTING
        @header_bar.style.background = TAC::Palette::TACNET_CONNECTING
      when :connection_error
        @tacnet_button.style.color = TAC::Palette::TACNET_CONNECTION_ERROR
        @header_bar.style.background = TAC::Palette::TACNET_CONNECTION_ERROR

        unless @page.is_a?(TAC::Pages::TACNET)
          push_state(TAC::Dialog::TACNETDialog, title: "TACNET Connection Error", message: window.backend.tacnet.full_status)
        end
      end

      @tacnet_button.style.default[:color] = @tacnet_button.style.color
      @header_bar.style.default[:background] = @header_bar.style.background

      @tacnet_button.recalculate
      @header_bar.recalculate

      request_repaint
    end

    window.width = Gosu.available_width / 2 if window.width < Gosu.available_width / 2
    window.height = Gosu.available_height / 2 if window.height < Gosu.available_height / 2

    if window.width != @window_width || window.height != @window_height
      @window_width = window.width
      @window_height = window.height

      recalc
    end
  end

  def button_down(id)
    super

    @page&.button_down(id)
  end

  def button_up(id)
    super

    @page&.button_up(id)
  end

  def recalc
    @window_controls.style.x = window.width - @window_controls.width
    @container.style.height = window.height - @header_bar.height
    @content.style.width = window.width - @navigation.width
    @body.style.height = window.height - (@chrome.height + @header_bar.height)


    request_recalculate
  end

  def page(klass, options = {})
    @menu_bar.clear
    @status_bar.clear
    @body.clear

    if window.backend.settings.config.empty? && page_requires_configuration?(klass)
      push_state(TAC::Dialog::AlertDialog, title: "No Config Loaded", message: "A config must be loaded.")
      page(TAC::Pages::Configurations)

      return
    end

    @page.blur if @page

    @pages[klass] = klass.new(host: self) unless @pages[klass]
    @page = @pages[klass]

    @page.options = options
    @page.setup
    @page.focus
  end

  def page_requires_configuration?(klass)
    [
      TAC::Pages::Editor,
      TAC::Pages::Presets,
      TAC::Pages::Search
    ].include?(klass)
  end
end
