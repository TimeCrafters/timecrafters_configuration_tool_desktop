module TAC
  class Pages
    class GameClock < Page
      def setup
        header_bar("Practice Game Clock")

        body.clear do
          stack(width: 1.0, height: 1.0) do
            label TAC::NAME, width: 1.0, text_size: 48, text_align: :center

            stack(width: 1.0, height: 8) do
              background 0xff_006000
            end
          end
        end
      end
    end
  end
end