module TAC
  class PracticeGameClock
    class ClockProxy
      def initialize(clock, jukebox)
        @clock = clock
        @jukebox = jukebox

        @callbacks = {}
      end

      def register(callback, method)
        @callbacks[callback] = method
      end

      def start_clock(mode)
        return if @clock.active? || $window.current_state.is_a?(Randomizer)

        @clock.controller = case mode
        when :full_match
          ClockController.new(0, ClockController::FULL_MATCH)
        when :autonomous
          ClockController.new(0, ClockController::AUTONOMOUS)
        when :full_teleop
          ClockController.new(33.0, ClockController::FULL_TELEOP)
        when :teleop_only
          ClockController.new(41.0, ClockController::TELEOP)
        when :endgame_only
          ClockController.new(131.0, ClockController::TELEOP_ENDGAME)
        else
          nil
        end
      end

      def abort_clock
        $window.current_state&.get_sample("media/fogblast.wav")&.play if @clock.active?
        @clock.controller = nil
      end

      def set_clock_title(string)
        @clock.title.text = string.to_s
        @clock.title.x = $window.width / 2 - @clock.title.width / 2
      end

      def get_clock_title(string)
        @clock.title
      end

      def jukebox_previous_track
        @jukebox.previous_track
      end

      def jukebox_next_track
        @jukebox.next_track
      end

      def jukebox_stop
        @jukebox.stop
      end

      def jukebox_play
        @jukebox.play
      end

      def jukebox_pause
        @jukebox.pause
      end

      def jukebox_set_volume(float)
        @jukebox.set_volume(float)
      end

      def jukebox_volume
        @jukebox.volume
      end

      def jukebox_current_track
        @jukebox.now_playing
      end

      def jukebox_set_sound_effects(boolean)
        @jukebox.set_sfx(boolean)
      end

      def jukebox_volume_changed(float)
        @callbacks[:volume_changed]&.call(float)
      end

      def jukebox_track_changed(name)
        @callbacks[:track_changed]&.call(name)
      end

      def randomizer_changed(boolean)
        @callbacks[:randomizer_changed]&.call(boolean)
      end

      def shutdown!
      end
    end
  end
end
