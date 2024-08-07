module TAC
  class PracticeGameClock
    class View < CyberarmEngine::GuiState

      attr_reader :clock

      def setup
        @remote_control_mode = @options[:remote_control_mode]
        window.show_cursor = !@remote_control_mode
        @escape_counter = 0

        @background_image = get_image("#{MEDIA_PATH}/background.png")
        # Preload duck image since Gosu and Windows threads don't get along with OpenGL (image is blank if loaded in a threaded context)
        get_image("#{MEDIA_PATH}/openclipart_ducky.png")
        @menu_background = 0xaa004000
        @mouse = Mouse.new(window)
        @clock = Clock.new
        @clock.controller = nil
        @last_clock_display_value = @clock.value
        @last_clock_title_value = @clock.title.text

        @particle_emitters = [
          PracticeGameClock::ParticleEmitter.new
        ]

        @last_clock_state = @clock.active?

        @locked_buttons_randomizer_visible = []
        @locked_buttons_clock_active  = []
        @randomizer_visible = false

        theme(THEME)

        @menu_container = flow width: 1.0 do
          stack(width: 0.35, padding: 5) do
            background @menu_background

            title "Match", width: 1.0, text_align: :center
            @start_match_btn = button "Start Match", width: 1.0, margin_bottom: 50 do |btn|
              @locked_buttons_clock_active << btn
              @locked_buttons_randomizer_visible << btn

              @clock_proxy.start_clock(:full_match)
            end

            title "Practice", width: 1.0, text_align: :center
            @autonomous_btn = button "Autonomous", width: 1.0 do |btn|
              @locked_buttons_clock_active << btn
              @locked_buttons_randomizer_visible << btn

              @clock_proxy.start_clock(:autonomous)
            end

            @teleop_with_countdown_btn = button "TeleOp with Countdown", width: 1.0 do |btn|
              @locked_buttons_clock_active << btn
              @locked_buttons_randomizer_visible << btn

              @clock_proxy.start_clock(:full_teleop)
            end

            @teleop_btn = button "TeleOp", width: 1.0 do |btn|
              @locked_buttons_clock_active << btn
              @locked_buttons_randomizer_visible << btn

              @clock_proxy.start_clock(:teleop_only)
            end

            @teleop_endgame_btn = button "TeleOp Endgame", width: 1.0 do |btn|
              @locked_buttons_clock_active << btn
              @locked_buttons_randomizer_visible << btn

              @clock_proxy.start_clock(:endgame_only)
            end

            @abort_match_btn = button "Abort Match", width: 1.0, margin_top: 50 do |btn|
              @locked_buttons_randomizer_visible << btn

              @clock_proxy.abort_clock
            end

            button "Close", width: 1.0, **TAC::THEME_DANGER_BUTTON do
              if window.instance_variable_get(:"@states").size == 1
                window.close
              else
                @server&.close

                @jukebox.stop
                window.fullscreen = false
                window.pop_state
              end
            end
          end

          stack width: 0.4, padding_left: 50 do
            background @menu_background

            flow(width: 1.0) do
              para "♫ Now playing:"
              @current_song_label = para "♫ ♫ ♫"
            end

            flow(width: 1.0) do
              para "Volume:"
              @current_volume_label = para "100%"
            end

            flow(width: 1.0) do
              button get_image("#{MEDIA_PATH}/icons/previous.png") do
                @jukebox.previous_track
              end

              button get_image("#{MEDIA_PATH}/icons/pause.png") do |button|
                if @jukebox.song && @jukebox.song.paused?
                  button.value = get_image("#{MEDIA_PATH}/icons/right.png")
                  @jukebox.play
                elsif !@jukebox.song
                  button.value = get_image("#{MEDIA_PATH}/icons/right.png")
                  @jukebox.play
                else
                  button.value = get_image("#{MEDIA_PATH}/icons/pause.png")
                  @jukebox.pause
                end
              end

              button get_image("#{MEDIA_PATH}/icons/stop.png") do
                @jukebox.stop
              end

              button get_image("#{MEDIA_PATH}/icons/next.png") do
                @jukebox.next_track
              end

              button get_image("#{MEDIA_PATH}/icons/minus.png"), margin_left: 20 do
                @jukebox.set_volume(@jukebox.volume - 0.1)
              end

              button get_image("#{MEDIA_PATH}/icons/plus.png") do
                @jukebox.set_volume(@jukebox.volume + 0.1)
              end

              button "Open Music Library", margin_left: 50 do
                if RUBY_PLATFORM.match(/ming|msys|cygwin/)
                  system("explorer #{MEDIA_PATH}/music")
                elsif RUBY_PLATFORM.match(/linux/)
                  system("xdg-open #{MEDIA_PATH}/music")
                else
                  # TODO.
                end
              end

              button get_image("#{MEDIA_PATH}/icons/musicOn.png"), margin_left: 50, tip: "Toggle Sound Effects" do |button|
                boolean = @jukebox.set_sfx(!@jukebox.play_sfx?)

                if boolean
                  button.value = get_image("#{MEDIA_PATH}/icons/musicOn.png")
                else
                  button.value = get_image("#{MEDIA_PATH}/icons/musicOff.png")
                end
              end
            end

            stack(width: 1.0) do
              @randomizer_btn = button "Randomizer", width: 1.0, **TAC::THEME_DANGER_BUTTON do |btn|
                unless @clock.active?
                  push_state(Randomizer)
                end
              end
            end
          end
        end

        @locked_buttons_clock_active.push(
          @start_match_btn,
          @autonomous_btn,
          @teleop_with_countdown_btn,
          @teleop_btn,
          @teleop_endgame_btn,
          @randomizer_btn
        )

        @locked_buttons_randomizer_visible.push(
          @start_match_btn,
          @autonomous_btn,
          @teleop_with_countdown_btn,
          @teleop_btn,
          @teleop_endgame_btn,
          @abort_match_btn
        )

        @jukebox = Jukebox.new(@clock)

        @clock_proxy = ClockProxy.new(@clock, @jukebox)

        if @remote_control_mode
          @server = ClockNet::Server.new(proxy_object: @clock_proxy)
          @server.start
          RemoteControl.server = @server

          @clock_proxy.register(:randomizer_changed, method(:randomizer_changed))
        end
      end

      def draw
        background_image_scale = [window.width.to_f / @background_image.width, window.height.to_f / @background_image.height].max

        @background_image.draw(0, 0, -3, background_image_scale, background_image_scale)
        @particle_emitters.each(&:draw)
        @clock.draw

        super
      end

      def update
        super
        @clock.update
        @mouse.update
        update_non_gui

        if @last_clock_state != @clock.active?
          @particle_emitters.each { |emitter| @clock.active? ? emitter.clock_active! : emitter.clock_inactive! }
        end

        if @remote_control_mode
          @menu_container.hide
        else
          if @mouse.last_moved < 1.5
            @menu_container.show unless @menu_container.visible?
            window.show_cursor = true
          else
            @menu_container.hide if @menu_container.visible?
            window.show_cursor = false
          end

          manage_button_enablement
        end

        if @clock.value != @last_clock_display_value
          @last_clock_display_value = @clock.value

          request_repaint

          if @remote_control_mode && @server.active_client
            @server.active_client.puts(ClockNet::PacketHandler.packet_clock_time(@last_clock_display_value))
          end
        end

        if @clock.title.text != @last_clock_title_value
          @last_clock_title_value = @clock.title.text

          request_repaint
        end

        if @last_track_name != @jukebox.current_track
          track_changed(@jukebox.current_track)
        end

        if @last_volume != @jukebox.volume
          volume_changed(@jukebox.volume)
        end

        @last_track_name = @jukebox.current_track
        @last_volume = @jukebox.volume
        @last_clock_state = @clock.active?
      end

      def needs_repaint?
        if @particle_emitters && @particle_emitters.map(&:particle_count).sum.positive?
          @needs_repaint = true
        else
          super
        end
      end

      def update_non_gui
        if @remote_control_mode
          while (o = RemoteControl.server.proxy_object.queue.shift)
            o.call
          end
        end

        @particle_emitters.each(&:update)
        @jukebox.update
      end

      def manage_button_enablement
        if @randomizer_visible
          @locked_buttons_randomizer_visible.each do |btn|
            btn.enabled = false
          end
        elsif @clock.active?
          @locked_buttons_clock_active.each do |btn|
            btn.enabled = false
          end
        else
          (@locked_buttons_clock_active + @locked_buttons_randomizer_visible).uniq.each do |btn|
            btn.enabled = true
          end
        end
      end

      def button_down(id)
        super

        @mouse.button_down(id)

        case id
        when Gosu::KB_ESCAPE
          @escape_counter += 1

          if @escape_counter >= 3
            @server&.close

            if window.instance_variable_get(:"@states").size == 1
              window.close
            else
              window.fullscreen = false
              window.pop_state
            end
          end
        else
          @escape_counter = 0
        end
      end

      def track_changed(name)
        @current_song_label.value = File.basename(name)
      end

      def volume_changed(float)
        @current_volume_label.value = "#{(float.round(1) * 100.0).round}%"
      end

      def randomizer_changed(boolean)
        @randomizer_visible = boolean

        if boolean
          push_state(Randomizer) unless @clock.active?
        else
          pop_state if current_state.is_a?(Randomizer)
        end
      end

      class Mouse
        def initialize(window)
          @window = window
          @last_moved = 0

          @last_position = CyberarmEngine::Vector.new(@window.mouse_x, @window.mouse_y)
        end

        def update
          position = CyberarmEngine::Vector.new(@window.mouse_x, @window.mouse_y)

          if  @last_position != position
            @last_position = position
            @last_moved = Gosu.milliseconds
          end
        end

        def button_down(id)
          case id
          when Gosu::MS_LEFT, Gosu::MS_MIDDLE, Gosu::MS_RIGHT
            @last_moved = Gosu.milliseconds
          end
        end

        def last_moved
          (Gosu.milliseconds - @last_moved) / 1000.0
        end
      end
    end
  end
end
