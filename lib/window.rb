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

    def close
      if @backend.config_changed?
        push_state(Dialog::ConfirmDialog, title: "Are you sure?", message: "Config has unsaved changes!", callback_method: proc { cleanup_and_close })
      else
        cleanup_and_close
      end
    end

    def cleanup_and_close
      if @backend.tacnet.connected?
        @backend.tacnet.close
      end

      close!
    end
  end
end