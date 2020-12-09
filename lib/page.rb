module TAC
  class Page
    include CyberarmEngine::DSL
    include CyberarmEngine::Common

    attr_reader :menu_bar, :status_bar, :body

    def initialize(host:, header_bar_label:, menu_bar:, status_bar:, body:)
      @host = host
      @header_bar_label = header_bar_label
      @menu_bar = menu_bar
      @status_bar = status_bar
      @body = body
    end

    def page(klass)
      @host.page(klass)
    end

    def header_bar(text)
      @header_bar_label.value = text
    end

    def setup
    end

    def focus
    end

    def blur
    end

    def draw
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end
  end
end