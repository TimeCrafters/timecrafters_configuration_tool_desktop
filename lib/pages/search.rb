module TAC
  class Pages
    class Search < Page
      def setup
        header_bar("Search")

        menu_bar.clear do
          search = edit_line "", width: 0.9, height: 1.0
          button get_image("#{TAC::ROOT_PATH}/media/icons/zoom.png"), image_height: 1.0 do
            unless search.value.strip.empty?
              search_results = search_config(search.value.downcase.strip)

              status_bar.clear do
                if search_results.results.size.zero?
                  subtitle "No results for: \"#{search.value.strip}\""
                else
                  subtitle "Search results for: \"#{search.value.strip}\""
                end
              end

              body.clear do
                flow(width: 1.0, height: 1.0) do
                  stack(width: 0.495, height: 1.0, scroll: true) do
                    shared_index = 0
                    if search_results.groups.size.positive?
                      title "Groups"

                      search_results.groups.each do |result|
                        stack(width: 1.0, **THEME_ITEM_CONTAINER_PADDING) do
                          background shared_index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR
                          button result.highlight(result.group.name), width: 1.0 do
                            page(TAC::Pages::Editor, { group: result.group, is_search: true })
                          end
                        end

                        shared_index += 1
                      end
                    end

                    if search_results.actions.size.positive?
                      title "Actions"

                      search_results.actions.each do |result|
                        stack(width: 1.0, **THEME_ITEM_CONTAINER_PADDING) do
                          background shared_index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR
                          button result.highlight(result.action.name), width: 1.0 do
                            page(TAC::Pages::Editor, { group: result.group, action: result.action, is_search: true })
                          end

                          if result.from_comment?
                            para result.highlight(result.action.comment), width: 1.0
                          end
                        end

                        shared_index += 1
                      end
                    end

                    if search_results.variables.size.positive?
                      title "Variables"

                      search_results.variables.each do |result|
                        stack(width: 1.0, **THEME_ITEM_CONTAINER_PADDING) do
                          background shared_index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR
                          button "#{result.highlight(result.variable.name)} [#{result.highlight(result.variable.value)}]", width: 1.0 do
                            page(TAC::Pages::Editor, { group: result.group, action: result.action, variable: result.variable, is_search: true })
                          end
                        end

                        shared_index += 1
                      end
                    end
                  end

                  stack(width: 0.495, height: 1.0, scroll: true) do
                    if search_results.group_presets.size.positive?
                      title "Group Presets"

                      search_results.group_presets.each do |result|
                        stack(width: 1.0, **THEME_ITEM_CONTAINER_PADDING) do
                          background shared_index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR
                          button result.highlight(result.group.name), width: 1.0 do
                            page(TAC::Pages::Editor, { group: result.group, group_is_preset: true, is_search: true })
                          end
                        end

                        shared_index += 1
                      end
                    end


                    if search_results.action_presets.size.positive?
                      title "Action Presets"

                      search_results.action_presets.each do |result|
                        stack(width: 1.0, **THEME_ITEM_CONTAINER_PADDING) do
                          background shared_index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR
                          button result.highlight(result.action.name), width: 1.0 do
                            if result.group.nil?
                              page(TAC::Pages::Editor, { action: result.action, action_is_preset: true, is_search: true })
                            else
                              page(TAC::Pages::Editor, { group: result.group, action: result.action, group_is_preset: true, is_search: true })
                            end
                          end

                          if result.from_comment?
                            para result.highlight(result.action.comment), width: 1.0
                          end
                        end

                        shared_index += 1
                      end
                    end

                    if search_results.variables_from_presets.size.positive?
                      title "Variables from Presets"

                      search_results.variables_from_presets.each do |result|
                        stack(width: 1.0, **THEME_ITEM_CONTAINER_PADDING) do
                          background shared_index.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR
                          button "#{result.highlight(result.variable.name)} [#{result.highlight(result.variable.value)}]", width: 1.0 do
                            if result.group.nil?
                              page(TAC::Pages::Editor, { action: result.action, variable: result.variable, action_is_preset: true, is_search: true })
                            else
                              page(TAC::Pages::Editor, { group: result.group, action: result.action, variable: result.variable, group_is_preset: true, is_search: true })
                            end
                          end
                        end

                        shared_index += 1
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

      def search_config(query)
        search_results = SearchResults.new

        search_groups(query, search_results)
        search_actions(query, search_results)
        search_variables(query, search_results)
        search_presets(query, search_results)

        return search_results
      end

      def search_groups(query, search_results)
        window.backend.config.groups.each do |group|
          if group.name.downcase.include?(query)
            result = SearchResult.new(group: group, query: query, is_group: true, is_from_name: true)
            search_results.results << result
          end
        end
      end

      def search_actions(query, search_results)
        window.backend.config.groups.each do |group|
          group.actions.each do |action|
            if action.name.downcase.include?(query)
              result = SearchResult.new(group: group, action: action, query: query, is_action: true, is_from_name: true)
              search_results.results << result
            end

            if action.comment.downcase.include?(query)
              result = SearchResult.new(group: group, action: action, query: query, is_action: true, is_from_comment: true)
              search_results.results << result
            end
          end
        end
      end

      def search_variables(query, search_results)
        window.backend.config.groups.each do |group|
          group.actions.each do |action|
            action.variables.each do |variable|
              if variable.name.downcase.include?(query)
                result = SearchResult.new(group: group, action: action, variable: variable, is_variable: true, query: query, is_from_name: true)
                search_results.results << result
              end

              if variable.value.downcase.include?(query)
                result = SearchResult.new(group: group, action: action, variable: variable, is_variable: true, query: query, is_from_value: true)
                search_results.results << result
              end
            end
          end
        end
      end

      def search_presets(query, search_results)
        window.backend.config.presets.groups.each do |group|
          if group.name.downcase.include?(query)
            result = SearchResult.new(group: group, query: query, is_group: true, is_from_name: true, is_preset: true)
            search_results.results << result
          end

          group.actions.each do |action|
            if action.name.downcase.include?(query)
              result = SearchResult.new(group: group, action: action, query: query, is_action: true, is_from_name: true, is_preset: true)
              search_results.results << result
            end

            if action.comment.downcase.include?(query)
              result = SearchResult.new(group: group, action: action, query: query, is_action: true, is_from_comment: true, is_preset: true)
              search_results.results << result
            end

            action.variables.each do |variable|
              if variable.name.downcase.include?(query)
                result = SearchResult.new(group: group, action: action, variable: variable, is_variable: true, query: query, is_from_name: true, is_preset: true)
                search_results.results << result
              end

              if variable.value.downcase.include?(query)
                result = SearchResult.new(group: group, action: action, variable: variable, is_variable: true, query: query, is_from_value: true, is_preset: true)
                search_results.results << result
              end
            end
          end
        end

        window.backend.config.presets.actions.each do |action|
            if action.name.downcase.include?(query)
              result = SearchResult.new(group: nil, action: action, query: query, is_action: true, is_from_name: true, is_preset: true)
              search_results.results << result
            end

            if action.comment.downcase.include?(query)
              result = SearchResult.new(group: nil, action: action, query: query, is_action: true, is_from_comment: true, is_preset: true)
              search_results.results << result
            end

            action.variables.each do |variable|
              if variable.name.downcase.include?(query)
                result = SearchResult.new(group: nil, action: action, variable: variable, is_variable: true, query: query, is_from_name: true, is_preset: true)
                search_results.results << result
              end

              if variable.value.downcase.include?(query)
                result = SearchResult.new(group: nil, action: action, variable: variable, is_variable: true, query: query, is_from_value: true, is_preset: true)
                search_results.results << result
              end
            end
        end
      end

      class SearchResults
        attr_reader :results

        def initialize
          @results = []
        end

        def groups
          @results.select { |result| result.group? && !result.preset? }
        end

        def actions
          @results.select { |result| result.action? && !result.preset? }
        end

        def variables
          @results.select { |result| result.variable? && !result.preset? }
        end

        def group_presets
          @results.select { |result| result.group? && result.preset? }
        end

        def action_presets
          @results.select { |result| result.action? && result.preset? }
        end

        def variables_from_presets
          @results.select { |result| result.variable? && result.preset? }
        end
      end

      class SearchResult
        attr_reader :group, :action, :variable, :query

        def initialize(query:, group:, action: nil, variable: nil,
                       is_group: false, is_action: false, is_variable: false,
                       is_from_name: false, is_from_value: false, is_from_comment: false, is_preset: false)
          @group = group
          @action = action
          @variable = variable
          @query = query

          @is_group = is_group
          @is_action = is_action
          @is_variable = is_variable

          @is_from_name = is_from_name
          @is_from_value = is_from_value
          @is_from_comment = is_from_comment
          @is_preset = is_preset
        end

        def group?
          @is_group
        end

        def action?
          @is_action
        end

        def variable?
          @is_variable
        end

        def from_name?
          @is_from_name
        end

        def from_value?
          @is_from_value
        end

        def from_comment?
          @is_from_comment
        end

        def preset?
          @is_preset
        end

        def highlight(string)
          string.gsub(/#{@query}/i, "<b><c=ff00ff>#{@query}</c></b>")
        end
      end
    end
  end
end