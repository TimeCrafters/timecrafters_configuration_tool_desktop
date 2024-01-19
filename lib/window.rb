module TAC
  class Window < CyberarmEngine::Window
    attr_reader :backend, :notification_manager

    def initialize(**args)
      super(**args)

      self.caption = "#{TAC::NAME} v#{TAC::VERSION} (#{TAC::RELEASE_NAME}) [#{TAC::RELEASE_DATE}]"
      @backend = Backend.new
      @notification_manager = CyberarmEngine::NotificationManager.new(window: self, edge: :bottom)

      if ARGV.join.include?("--game-clock-remote-display")
        push_state(PracticeGameClock::View, remote_control_mode: true)
      elsif ARGV.join.include?("--intro")
        push_state(CyberarmEngine::IntroState, forward: TAC::States::Boot)
      else
        push_state(TAC::States::Boot)
      end
    end

    def draw
      super

      Gosu.flush
      @notification_manager.draw
    end

    def update
      @notification_manager.update

      super
    end

    def needs_redraw?
      states.any?(&:needs_repaint?) || @notification_manager.instance_variable_get(:@drivers).size.positive?
    end

    def toast(title, message = nil)
      @notification_manager.create_notification(
        priority: CyberarmEngine::Notification::PRIORITY_HIGH,
        title: title,

        tagline: message ? message : "",
        edge_color: THEME_NOTIFICATION_EDGE_COLOR,
        background_color: THEME_NOTIFICATION_BACKGROUND,
        title_color: THEME_NOTIFICATION_TITLE_COLOR,
        tagline_color: THEME_NOTIFICATION_TAGLINE_COLOR
      )
    end

    def hit_test(x, y)
      return 0 unless BORDERLESS

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
        push_state(Dialog::ConfirmDialog, title: "Unsaved Config", message: "Config has unsaved changes that will be lost if you continue!", callback_method: proc { cleanup_and_close })
      elsif @backend.settings_changed?
        push_state(Dialog::ConfirmDialog, title: "Unsaved Settings", message: "Settings has unsaved changes that will be lost if you continue!", callback_method: proc { cleanup_and_close })
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
