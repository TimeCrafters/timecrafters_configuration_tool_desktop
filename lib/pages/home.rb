module TAC
  class Pages
    class Home < Page
      def setup
        header_bar(TAC::NAME)

        body.clear do
          stack(width: 1.0, height: 1.0) do
            para TAC::NAME, width: 1.0, text_size: 48, text_align: :center

            stack(width: 1.0, height: 8) do
              background 0xff_006000
            end

            if window.backend.settings.config.empty?
              para "TODO: Introduction"
              para "Get Started", text_size: 28
              button "1. Create a configuration" do
                page(TAC::Pages::Configurations)
              end
              para "2. Add a group"
              para "3. Add an action"
              para "4. Add a variable"
              para "5. Profit?"
            else
              para "Display config stats or something?"

              config = window.backend.config
              groups = config.groups
              actions = config.groups.map { |g| g.actions }.flatten
              variables = actions.map { |a| a.variables }.flatten

              para "Total groups: #{groups.size}"
              para "Total actions: #{actions.size}"
              para "Total variables: #{variables.size}"
            end

            stack(width: 1.0, fill: true, scroll: true, margin_top: 32) do
              heading, items = Gosu::LICENSES.split("\n\n")

              title heading

              items.split("\n").each do |item|
                name, website, license, license_website = item.split(",").map(&:strip)
                flow(width: 1.0, height: 28) do
                  tagline "#{name} - "
                  button "Website", height: 1.0, tip: website do
                    open_url(website)
                  end
                end

                flow(width: 1.0, height: 22, margin_bottom: 20) do
                  para "#{license} - "
                  button "License Website", height: 1.0, text_size: 16, tip: license_website do
                    open_url(license_website)
                  end
                end
              end
            end
          end
        end
      end

      def open_url(url)
        case RUBY_PLATFORM
        when /mingw/ # windows
          system("start #{url}")
        when /linux/
          system("xdg-open #{url}")
        when /darwin/ # macos
          system("open #{url}")
        end
      end
    end
  end
end