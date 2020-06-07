module TAC
  class Window < CyberarmEngine::Window
    def initialize(**args)
      super(**args)

      self.caption = "#{TAC::NAME} v#{TAC::VERSION} (#{TAC::RELEASE_NAME})"
      push_state(TAC::States::Editor)
    end

    def needs_cursor?
      true
    end
  end
end