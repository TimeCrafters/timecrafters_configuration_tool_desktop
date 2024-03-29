module TAC
  class PracticeGameClock
    class RemoteControl
      @@connection = nil
      @@server = nil

      def self.connection
        @@connection
      end

      def self.connection=(connection)
        @@connection = connection
      end

      def self.server
        @@server
      end

      def self.server=(server)
        @@server = server
      end

      class NetConnect < CyberarmEngine::GuiState
        def setup
          theme(THEME)

          background Palette::TACNET_NOT_CONNECTED

          banner "ClockNet Remote Control", text_align: :center, width: 1.0
          flow(width: 1.0) do
            stack(width: 0.25) {}
            stack(width: 0.5) do
              title "Hostname"
              @hostname = edit_line "localhost", width: 1.0
              title "Port"
              @port = edit_line "4567", width: 1.0

              flow(width: 1.0, margin_top: 20) do
                @back_button = button "Back", width: 0.5 do
                  window.pop_state
                end

                @connect_button = button "Connect", width: 0.5 do
                  begin
                    @connect_button.enabled = false
                    @back_button.enabled = false

                    @connection = ClockNet::Connection.new(hostname: @hostname.value, port: Integer(@port.value), proxy_object: RemoteProxy.new(window))

                    @connection.connect
                    RemoteControl.connection = @connection
                  end
                end
              end
            end
          end
        end

        def update
          super

          if RemoteControl.connection
            push_state(Controller) if RemoteControl.connection.connected?

            RemoteControl.connection = nil if RemoteControl.connection.client.socket_error?
          else
            @back_button.enabled = true
            @connect_button.enabled = true
          end
        end
      end

      class Controller < CyberarmEngine::GuiState
        def setup
          theme(THEME)

          at_exit do
            @connection&.close
          end

          @jukebox_volume = 1.0
          @jukebox_sound_effects = true
          @locked_buttons_randomizer_visible = []
          @locked_buttons_clock_active  = []
          @randomizer_visible = false
          @clock_updated_at = -1000

          RemoteControl.connection.proxy_object.register(:track_changed, method(:track_changed))
          RemoteControl.connection.proxy_object.register(:volume_changed, method(:volume_changed))
          RemoteControl.connection.proxy_object.register(:clock_changed, method(:clock_changed))
          RemoteControl.connection.proxy_object.register(:randomizer_changed, method(:randomizer_changed))

          background Palette::TACNET_NOT_CONNECTED

          banner "ClockNet Remote Control", text_align: :center, width: 1.0

          flow width: 1.0, height: 1.0 do
            stack width: 0.5 do
              title "Match", width: 1.0, text_align: :center
              @start_match_btn = button "Start Match", width: 1.0, text_size: 48, margin_bottom: 50 do
                start_clock(:full_match)
              end

              title "Practice", width: 1.0, text_align: :center
              @autonomous_btn = button "Autonomous", width: 1.0 do
                start_clock(:autonomous)
              end
              @teleop_with_countdown_btn = button "TeleOp with Countdown", width: 1.0 do
                start_clock(:full_teleop)
              end
              @teleop_btn = button "TeleOp", width: 1.0 do
                start_clock(:teleop_only)
              end
              @teleop_endgame_btn = button "TeleOp Endgame", width: 1.0, margin_bottom: 50 do
                start_clock(:endgame_only)
              end

              @abort_match_btn = button "Abort Match", width: 1.0 do
                RemoteControl.connection.puts(ClockNet::PacketHandler.packet_abort_clock)
              end

              button "Shutdown", width: 1.0, **TAC::THEME_DANGER_BUTTON do
                RemoteControl.connection.puts(ClockNet::PacketHandler.packet_shutdown)
                sleep 1 # let packet escape before closing
              end
            end

            stack width: 0.495 do
              title "Clock Title", width: 1.0, text_align: :center

              stack width: 0.9, margin_left: 50 do
                @title = edit_line "FIRST TECH CHALLENGE", width: 1.0

                button "Update", width: 1.0, margin_bottom: 50 do
                  RemoteControl.connection.puts(ClockNet::PacketHandler.packet_set_clock_title(@title.value.strip))
                end
              end

              title "JukeBox", width: 1.0, text_align: :center
              stack width: 0.9, margin_left: 50 do
                flow width: 1.0 do
                  tagline "Now Playing: "
                  @track_name = tagline ""
                end

                flow width: 1.0 do
                  tagline "Volume: "
                  @volume = tagline "100%"
                end

                flow width: 1.0 do
                  button get_image("#{MEDIA_PATH}/icons/previous.png") do
                    RemoteControl.connection.puts(ClockNet::PacketHandler.packet_jukebox_previous_track)
                  end

                  button get_image("#{MEDIA_PATH}/icons/right.png") do |button|
                    if @jukebox_playing
                      RemoteControl.connection.puts(ClockNet::PacketHandler.packet_jukebox_pause)
                      button.value = get_image("#{MEDIA_PATH}/icons/right.png")
                      @jukebox_playing = false
                    else
                      RemoteControl.connection.puts(ClockNet::PacketHandler.packet_jukebox_play)
                      button.value = get_image("#{MEDIA_PATH}/icons/pause.png")
                      @jukebox_playing = true
                    end
                  end

                  button get_image("#{MEDIA_PATH}/icons/stop.png") do
                    RemoteControl.connection.puts(ClockNet::PacketHandler.packet_jukebox_stop)
                  end

                  button get_image("#{MEDIA_PATH}/icons/next.png") do
                    RemoteControl.connection.puts(ClockNet::PacketHandler.packet_jukebox_next_track)
                  end

                  button get_image("#{MEDIA_PATH}/icons/minus.png"), margin_left: 20 do
                    @jukebox_volume -= 0.1
                    @jukebox_volume = 0.1 if @jukebox_volume < 0.1
                    RemoteControl.connection.puts(ClockNet::PacketHandler.packet_jukebox_set_volume(@jukebox_volume))
                  end

                  button get_image("#{MEDIA_PATH}/icons/plus.png") do
                    @jukebox_volume += 0.1
                    @jukebox_volume = 1.0 if @jukebox_volume > 1.0
                    RemoteControl.connection.puts(ClockNet::PacketHandler.packet_jukebox_set_volume(@jukebox_volume))
                  end

                  button get_image("#{MEDIA_PATH}/icons/musicOn.png"), margin_left: 20, tip: "Toggle Sound Effects" do |button|
                    if @jukebox_sound_effects
                      button.value = get_image("#{MEDIA_PATH}/icons/musicOff.png")
                      @jukebox_sound_effects = false
                    else
                      button.value = get_image("#{MEDIA_PATH}/icons/musicOn.png")
                      @jukebox_sound_effects = true
                    end

                    RemoteControl.connection.puts(ClockNet::PacketHandler.packet_jukebox_set_sound_effects(@jukebox_sound_effects))
                  end
                end

                button "Open Music Library", width: 1.0 do
                  path = "#{MEDIA_PATH}/music"

                  if RUBY_PLATFORM.match(/ming|msys|cygwin/)
                    system("explorer \"#{path.gsub("/", "\\")}\"")
                  elsif RUBY_PLATFORM.match(/linux/)
                    system("xdg-open \"#{MEDIA_PATH}/music\"")
                  else
                    # TODO.
                  end
                end
              end

              stack width: 0.9, margin_left: 50, margin_top: 20 do
                flow width: 1.0 do
                  title "Clock: "
                  @clock_label = title "0:00"
                end

                flow width: 1.0 do
                  title "Randomizer: "
                  @randomizer_label = title "Not Visible"
                end

                @randomizer_btn = button "Randomizer", width: 1.0, **TAC::THEME_DANGER_BUTTON do
                  @randomizer_visible = !@randomizer_visible

                  RemoteControl.connection.puts(ClockNet::PacketHandler.packet_randomizer_visible(@randomizer_visible))
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
        end

        def update
          super

          while (o = RemoteControl.connection.proxy_object.queue.shift)
            o.call
          end

          manage_button_enablement

          return if RemoteControl.connection.connected?

          # We've lost connection, unset window's connection object
          # and send user back to connect screen to to attempt to
          # reconnect
          RemoteControl.connection = nil
          pop_state
        end

        def start_clock(mode)
          RemoteControl.connection.puts(ClockNet::PacketHandler.packet_start_clock(mode.to_s))
        end

        def track_changed(name)
          @track_name.value = name
        end

        def volume_changed(float)
          @volume.value = "#{(float.round(1) * 100.0).round}%"
        end

        def clock_changed(string)
          @clock_updated_at = Gosu.milliseconds if @clock_label.value != string

          @clock_label.value = string
        end

        def randomizer_changed(boolean)
          @randomizer_label.value = "Visible" if boolean
          @randomizer_label.value = "Not Visible" unless boolean
        end

        def manage_button_enablement
          if @randomizer_visible
            @locked_buttons_randomizer_visible.each do |btn|
              btn.enabled = false
            end
          elsif Gosu.milliseconds - @clock_updated_at <= 1_250
            @locked_buttons_clock_active.each do |btn|
              btn.enabled = false
            end
          else
            (@locked_buttons_clock_active + @locked_buttons_randomizer_visible).uniq.each do |btn|
              btn.enabled = true
            end
          end
        end
      end
    end
  end
end
