module TAC
  class Window < CyberarmEngine::Window
    attr_reader :backend
    def initialize(**args)
      super(**args)

      self.caption = "#{TAC::NAME} v#{TAC::VERSION} (#{TAC::RELEASE_NAME})"
      @backend = Backend.new
      push_state(TAC::States::Editor)
    end

    def needs_cursor?
      true
    end
  end
end