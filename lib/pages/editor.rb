module TAC
  class Pages
    class Editor < Page
      def setup
        header_bar("Editor")

        body.clear do
          flow(width: 1.0, height: 1.0) do
            stack(width: 0.3333, height: 1.0) do
              background 0xff_550055
            end
            stack(width: 0.3333, height: 1.0) do
              background 0xff_555555
            end
            stack(width: 0.3333, height: 1.0) do
              background 0xff_55ff55
            end
          end
        end
      end
    end
  end
end