module TAC
  class Dialog
    class PickPresetDialog < Dialog
      def build
        @limit = @options[:limit]

        list = window.backend.config.presets.groups if @limit == :groups
        list = window.backend.config.presets.actions if @limit == :actions

        background Gosu::Color::GRAY

        stack(width: 1.0, height: 512, scroll: true) do
          list.each do |item|
            button item.name, width: 1.0 do
              close
              @options[:callback_method].call(item)
            end
          end
        end
      end

      def try_commit
      end
    end
  end
end