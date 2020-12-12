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

    def hit_test(x, y)
      if y <= 4
        return 2 if x <= 4
        return 4 if x >= width - 4
        return 3
      end

      if y >= height - 4
        return 8 if x <= 4
        return 6 if x >= width - 4
        return 7
      end

      return 1 if y <= 36 && x <= width - (36 * 3 + 4 * 6)

      0
    end

    def close
      if @backend.config_changed?
        push_state(Dialog::ConfirmDialog, title: "Unsaved Config", message: "Config has unsaved changes\nthat will be lost if you continue!", callback_method: proc { cleanup_and_close })
      elsif @backend.settings_changed?
        push_state(Dialog::ConfirmDialog, title: "Unsaved Settings", message: "Settings has unsaved changes\nthat will be lost if you continue!", callback_method: proc { cleanup_and_close })
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
