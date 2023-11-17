module TAC
  class PracticeGameClock
    module EventHandlers
      ### Clock ###
      def start_clock
        @clock_running = true
      end

      def stop_clock
        @clock_running = false
      end

      def change_clock(value)
        @clock_time = time_from_string(value)
      end

      ### Countdown ###
      def start_countdown
        @countdown_running = true
      end

      def stop_countdown
        @countdown_running = false
      end


      def change_countdown(value)
        @countdown_time = time_from_string(value)
      end

      def change_display(display)
      end

      def change_color(color)
        out = case color
        when :white
          Gosu::Color::WHITE
        when :orange
          Gosu::Color.rgb(150, 75, 0)
        when :red
          Gosu::Color.rgb(150, 0, 0)
        end

        ### --- ###
        # OVERRIDE: offical CenterStage game clock no longer has colors
        ### --- ###

        out = Gosu::Color::WHITE

        @display_color = out
      end

      private def time_from_string(string)
        split = string.split(":")
        minutes = (split.first.to_i) * 60
        seconds = (split.last.to_i)

        return minutes + seconds
      end

      def play_sound(sound)
        path = nil
        case sound
        when :autonomous_countdown
          path = "media/sounds/3-2-1.wav"
        when :autonomous_start
          path = "media/sounds/charge.wav"
        when :autonomous_ended
          path = "media/sounds/endauto.wav"
        when :teleop_pickup_controllers
          path = "media/sounds/Pick_Up_Controllers.wav"
        when :abort_match
          path = "media/sounds/fogblast.wav"
        when :teleop_countdown
          path = "media/sounds/3-2-1.wav"
        when :teleop_started
          path = "media/sounds/firebell.wav"
        when :end_game
          path = "media/sounds/factwhistle.wav"
        when :end_match
          path = "media/sounds/endmatch.wav"
        end

        path = "#{ROOT_PATH}/#{path}"

        if path && File.exist?(path) && !File.directory?(path)
          Jukebox::SAMPLES[path] = Gosu::Sample.new(path) unless Jukebox::SAMPLES[path].is_a?(Gosu::Sample)
          Jukebox::SAMPLES[path].play
        else
          warn "WARNING: Sample for #{sound.inspect} could not be found at '#{path}'"
        end
      end
    end
  end
end
