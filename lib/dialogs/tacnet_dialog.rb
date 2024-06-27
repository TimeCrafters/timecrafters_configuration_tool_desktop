module TAC
  class Dialog
    class TACNETDialog < Dialog
      def build
        @dialog_root.style.default[:border_color] = [ Palette::TACNET_PRIMARY, Palette::TACNET_SECONDARY ]
        @titlebar.style.default[:background] = [ Palette::TACNET_PRIMARY, Palette::TACNET_SECONDARY ]

        background Gosu::Color::GRAY
        para @options[:message], width: 1.0

        @sound = Gosu::Sample.new("#{TAC::MEDIA_PATH}/error_alarm.ogg").play(1, 1, true)

        button "Close", width: 1.0, margin_top: THEME_DIALOG_BUTTON_PADDING do
          try_commit
        end
      end

      def try_commit
        close
      end

      def close
        super

        @sound.stop
      end
    end
  end
end