module TAC
  class Window < CyberarmEngine::Window
    attr_reader :backend
    def initialize(**args)
      super(**args)

      self.caption = "#{TAC::NAME} v#{TAC::VERSION} (#{TAC::RELEASE_NAME})"
      @backend = Backend.new
      push_state(TAC::States::Boot)
    end

    def needs_cursor?
      true
    end

    def close
      if @backend.config_changed?
        push_state(Dialog::ConfirmDialog, title: "Unsaved Config", message: "Config has unsaved changes\nthat will be lost if\nyou continue!", callback_method: proc { cleanup_and_close })
      elsif @backend.settings_changed?
        push_state(Dialog::ConfirmDialog, title: "Unsaved Settings", message: "Settings has unsaved changes\nthat will be lost if\nyou continue!", callback_method: proc { cleanup_and_close })
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