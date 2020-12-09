module TAC
  class Pages
    class Home < Page
      def setup
        header_bar(TAC::NAME)

        body.clear do
          stack(width: 1.0, height: 1.0) do
            label TAC::NAME, width: 1.0, text_size: 48, text_align: :center

            stack(width: 1.0, height: 8) do
              background 0xff_006000
            end

            if window.backend.settings.config.empty?
              label "TODO: Introduction"
              label "Get Started", text_size: 28
              button "1. Create a configuration" do
                page(TAC::Pages::Configurations)
              end
              label "2. Add a group"
              label "3. Add an action"
              label "4. Add a variable"
              label "5. Profit?"
            else
              label "Display config stats or something?"

              config = window.backend.config
              groups = config.groups
              actions = config.groups.map { |g| g.actions }.flatten
              variables = actions.map { |a| a.variables }.flatten

              label "Total groups: #{groups.size}"
              label "Total actions: #{actions.size}"
              label "Total variables: #{variables.size}"
            end
          end
        end
      end
    end
  end
end