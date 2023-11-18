module TAC
  class PracticeGameClock
    class Jukebox
      MUSIC = Dir.glob(MEDIA_PATH + "/music/*.*").freeze
      SAMPLES = {}

      if File.exist?(MEDIA_PATH + "/sounds/skystone")
        BEEPS_AND_BOOPS = Dir.glob(MEDIA_PATH + "/sounds/skystone/*.*").freeze
      end

      attr_reader :volume, :now_playing

      def initialize(clock)
        @clock = clock

        @order = MUSIC.shuffle
        @now_playing = ""
        @playing = false
        @song = nil
        @volume = 1.0
        @last_check_time = Gosu.milliseconds

        @last_sfx_time = Gosu.milliseconds
        @sfx_random_interval = generate_sfx_period
        @play_sfx = true

        if defined?(BEEPS_AND_BOOPS)
          BEEPS_AND_BOOPS.each do |beep|
            SAMPLES[beep] = Gosu::Sample.new(beep)
          end
        end
      end

      def update
        return unless Gosu.milliseconds - @last_check_time >= 2000.0

        @last_check_time = Gosu.milliseconds

        if @song && !@song.playing? && !@song.paused?
          next_track if @playing
        end

        if @play_sfx && defined?(BEEPS_AND_BOOPS)
          play_sfx
        end
      end

      def play_sfx
        if Gosu.milliseconds - @last_sfx_time >= @sfx_random_interval
          @last_sfx_time = Gosu.milliseconds
          @sfx_random_interval = generate_sfx_period

          pan = rand(0.49999..0.50001)
          volume = rand(0.75..1.0)
          speed = rand(0.5..1.25)
          SAMPLES[BEEPS_AND_BOOPS.sample].play_pan(pan, volume, speed) unless @clock.active?
        end
      end

      def generate_sfx_period
        #  rand(15..120) * 1000.0
        rand(5..10) * 1000.0
      end

      def set_sfx(boolean)
        @play_sfx = boolean
      end

      def play_sfx?
        @play_sfx
      end

      def play
        if @song && @song.paused?
          @song.play
        else
          return false unless @order.size > 0

          @current_song = @order.first
          @song = Gosu::Song.new(@current_song)
          @song.volume = @volume
          @song.play
          @now_playing = File.basename(@current_song)
          @order.rotate!(1)
        end

        @playing = true
      end

      def pause
        @playing = false
        @song.pause if @song
      end

      def song
        @song
      end

      def stop
        @song.stop if @song
        @playing = false
        @now_playing = ""
      end

      def previous_track
        return false unless @order.size > 0

        @song.stop if @song
        @order.rotate!(-1)
        @current_song = @order.first
        @song = Gosu::Song.new(@current_song)
        @song.volume = @volume
        @song.play

        @playing = true
        @now_playing = File.basename(@current_song)
      end

      def next_track
        return false unless @order.size > 0

        @song.stop if @song
        @current_song = @order.first
        @song = Gosu::Song.new(@current_song)
        @song.volume = @volume
        @song.play
        @order.rotate!(1)

        @playing = true
        @now_playing = File.basename(@current_song)
      end

      def current_track
        @current_song
      end

      def set_volume(float)
        @volume = float
        @volume = @volume.clamp(0.1, 1.0)
        @song.volume = @volume if @song
      end
    end
  end
end
