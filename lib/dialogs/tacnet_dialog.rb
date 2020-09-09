module TAC
  class Dialog
    class TACNETDialog < Dialog
      def build
        @dialog_root.style.border_color = [ Palette::TACNET_PRIMARY, Palette::TACNET_SECONDARY ]
        @titlebar.style.background = [ Palette::TACNET_PRIMARY, Palette::TACNET_SECONDARY ]

        background Gosu::Color::GRAY
        label @options[:message]

        @sound = Gosu::Sample.new(TAC::ROOT_PATH + "/media/error_alarm.ogg").play(1, 1, true)

        button "Close", width: 1.0 do
          close
        end
      end

      def close
        super

        @sound.stop
      end
    end
  end
end