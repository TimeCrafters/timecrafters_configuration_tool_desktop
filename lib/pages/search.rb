module TAC
  class Pages
    class Search < Page
      def setup
        header_bar("Search")

        menu_bar.clear do
          search = edit_line "", width: 0.9, height: 1.0
          button get_image("#{TAC::ROOT_PATH}/media/icons/zoom.png"), image_height: 1.0 do
            # do search
            body.clear do
              label "Search results for: #{search.value.strip}"
              label "TODO: Search Results."
            end
          end
        end
      end
    end
  end
end