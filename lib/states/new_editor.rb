class NewEditor < CyberarmEngine::GuiState
  include CyberarmEngine::Theme # get access to deep_merge method
  attr_reader :header_bar, :header_bar_label, :navigation, :content, :menu_bar, :status_bar, :body

  def setup
    @window_width = 0
    @window_height = 0

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

      @header_bar_label = label TAC::NAME, width: 1.0, text_align: :center, text_size: 32

      @window_controls = flow(x: window.width - 36 * 2, y: 0, height: 1.0) do
        button get_image("#{TAC::ROOT_PATH}/media/icons/minus.png"), tip: "Minimize", image_height: 1.0 do
          window.minimize if window.respond_to?(:minimize)
        end

        button get_image("#{TAC::ROOT_PATH}/media/icons/larger.png"), tip: "Maximize", image_height: 1.0 do |btn|
          window.maximize if window.respond_to?(:maximize)
        end

        button get_image("#{TAC::ROOT_PATH}/media/icons/cross.png"), tip: "Exit", image_height: 1.0, **TAC::THEME_DANGER_BUTTON do
          window.close
        end
      end
    end

    @container = flow(width: 1.0, height: 1.0) do
      @navigation = stack(width: 64, height: 1.0) do
        background 0xff_333333

        button get_image("#{TAC::ROOT_PATH}/media/icons/home.png"), margin: 4, tip: "Home", image_width: 1.0 do
          page(TAC::Pages::Home)
        end

        button get_image("#{TAC::ROOT_PATH}/media/icons/menuList.png"), margin: 4, tip: "Editor", image_width: 1.0 do
          page(TAC::Pages::Editor)
        end

        @tacnet_button = button get_image("#{TAC::ROOT_PATH}/media/icons/signal3.png"), margin: 4, tip: "TACNET", image_width: 1.0 do
          page(TAC::Pages::TACNET)
        end

        button get_image("#{TAC::ROOT_PATH}/media/icons/right.png"), margin: 4, tip: "Simulator", image_width: 1.0 do
          page(TAC::Pages::Simulator)
        end

        button get_image("#{TAC::ROOT_PATH}/media/icons/gear.png"), margin: 4, tip: "Configurations", image_width: 1.0 do
          page(TAC::Pages::Configurations)
        end

        button get_image("#{TAC::ROOT_PATH}/media/icons/menuGrid.png"), margin: 4, tip: "Presets", image_width: 1.0 do
          page(TAC::Pages::Presets)
        end

        button get_image("#{TAC::ROOT_PATH}/media/icons/zoom.png"), margin: 4, tip: "Search", image_width: 1.0 do
          page(TAC::Pages::Search)
        end
      end

      @content = stack(width: window.width - @navigation.style.width, height: 1.0) do
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

    page(TAC::Pages::Home)
  end

  def draw
    super

    @page.draw if @page
  end

  def update
    super

    @page.update if @page

    case window.backend.tacnet.status
    when :not_connected
      @tacnet_button.style.color = Gosu::Color::WHITE
    when :connecting
      @tacnet_button.style.color = TAC::Palette::TACNET_CONNECTING
    when :connected
      @tacnet_button.style.color = TAC::Palette::TACNET_CONNECTED
    when :connection_error
      @tacnet_button.style.color = TAC::Palette::TACNET_CONNECTION_ERROR
    end

    window.width = Gosu.available_width / 2 if window.width < Gosu.available_width / 2
    window.height = Gosu.available_height / 2 if window.height < Gosu.available_height / 2

    if window.width != @window_width || window.height != @window_height
      @window_width = window.width
      @window_height = window.height

      recalc
    end
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

    if window.backend.settings.config.empty?
      if [TAC::Pages::Home, TAC::Pages::TACNET, TAC::Pages::Simulator, TAC::Pages::Configurations].include?(klass)
      else
        push_state(TAC::Dialog::AlertDialog, title: "No Config Loaded", message: "A config must be loaded.")
        page(TAC::Pages::Configurations)

        return
      end
    end

    @page.blur if @page

    @pages[klass] = klass.new(host: self) unless @pages[klass]
    @page = @pages[klass]

    @page.options = options
    @page.setup
    @page.focus
  end
end