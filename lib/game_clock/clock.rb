module TAC
  class PracticeGameClock
    class Clock
      CLOCK_SIZE = Gosu.screen_height
      TITLE_SIZE = 128

      attr_reader :title

      def initialize
        @title = CyberarmEngine::Text.new("FIRST TECH CHALLENGE", size: TITLE_SIZE, text_shadow: true, y: 10, color: Gosu::Color::GRAY)
        @title.x = $window.width / 2 - @title.width / 2

        @text = CyberarmEngine::Text.new(":1234567890", size: CLOCK_SIZE, text_shadow: true, shadow_size: 2, shadow_color: Gosu::Color::GRAY)
        @text.width # trigger font-eager loading

        @title.z, @text.z = -1, -1

        @controller = nil
      end

      def controller=(controller)
        @controller = controller
      end

      def draw
        @title.draw
        @text.draw
      end

      def update
        @title.x = $window.width / 2 - @title.width / 2

        if @controller
          @text.color = @controller.display_color
          @text.text = clock_time(@controller.time_left)
        else
          @text.color = Gosu::Color::WHITE
          @text.text = "0:00"
        end

        @text.x = $window.width / 2 - @text.textobject.text_width("0:00") / 2
        @text.y = $window.height / 2 - @text.height / 2

        @controller&.update
      end

      def active?
        if @controller
          @controller.clock? || @controller.countdown?
        else
          false
        end
      end

      def value
        @text.text
      end

      def clock_time(time_left)
        minutes = ((time_left + 0.5) / 60.0).floor

        seconds = time_left.round % 60
        seconds = "0#{seconds}" if seconds < 10

        return "#{minutes}:#{seconds}" if time_left.round.even?
        return "#{minutes}<c=999999>:</c>#{seconds}" if time_left.round.odd?
      end
    end
  end
end
