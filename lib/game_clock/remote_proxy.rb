module TAC
  class PracticeGameClock
    class RemoteProxy
      def initialize(window)
        @window = window

        @callbacks = {}
      end

      def register(callback, method)
        @callbacks[callback] = method
      end

      def start_clock(mode)
      end

      def abort_clock
      end

      def set_clock_title(string)
      end

      def get_clock_title(string)
      end

      def jukebox_previous_track
      end

      def jukebox_next_track
      end

      def jukebox_stop
      end

      def jukebox_play
      end

      def jukebox_pause
      end

      def jukebox_sound_effects(boolean)
      end

      def volume_changed(float)
        @callbacks[:volume_changed]&.call(float)
      end

      def track_changed(name)
        @callbacks[:track_changed]&.call(name)
      end

      def clock_changed(string)
        @callbacks[:clock_changed]&.call(string)
      end

      def randomizer_changed(boolean)
        @callbacks[:randomizer_changed]&.call(boolean)
      end

      def shutdown!
      end
    end
  end
end
