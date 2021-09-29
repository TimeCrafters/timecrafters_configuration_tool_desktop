module TAC
  class Pages
    class GameClock < Page
      def setup
        header_bar("Game Clock")

        body.clear do
          flow(width: 1.0, height: 1.0) do
            @command_options = flow(width: 1.0) do
              stack(width: 0.3) do
              end

              stack(width: 0.4) do
                banner "Choose Mode", width: 1.0, text_align: :center
                title "Local", width: 1.0, text_align: :center

                button "Game Clock", width: 1.0 do
                  push_state(PracticeGameClock::View)

                  window.fullscreen = true
                end

                button "Dual Screen Game Clock", width: 1.0 do
                  # Spawn game clock window
                  $clock_pid = Process.spawn(
                    RbConfig.ruby,
                    "#{ROOT_PATH}/timecrafters_configuration_tool.rb",
                    "--game-clock-remote-display"
                  )


                  # switch to remote control
                  push_state(PracticeGameClock::RemoteControl::NetConnect)
                end

                title "Remote", width: 1.0, text_align: :center, margin_top: 32
                button "Game Clock Display", width: 1.0 do
                  push_state(PracticeGameClock::View, remote_control_mode: true)

                  window.fullscreen = true
                end

                button "Game Clock Remote Control", width: 1.0 do
                  push_state(PracticeGameClock::RemoteControl::NetConnect)
                end
              end

              stack(width: 0.3) do
              end
            end
          end
        end
      end
    end
  end
end