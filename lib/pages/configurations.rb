module TAC
  class Pages
    class Configurations < Page
      def setup
        header_bar("Manage Configurations")

        menu_bar.clear do
          button get_image("#{TAC::MEDIA_PATH}/icons/plus.png"), image_height: 1.0, tip: "Add configuration" do
            push_state(Dialog::NamePromptDialog, title: "Config Name", callback_method: proc { |name|
              window.backend.write_new_config(name)

              change_config(name)
              populate_configs
            })
          end

          button "Open Folder", tip: "Open folder containing configurations", height: 1.0 do
            if RUBY_PLATFORM =~ /mingw/
              system("explorer \"#{TAC::CONFIGS_PATH.gsub("/", "\\")}\"")
            elsif RUBY_PLATFORM =~ /darwin/
              system("open \"#{TAC::CONFIGS_PATH}\"")
            else
              system("xdg-open \"#{TAC::CONFIGS_PATH}\"")
            end
          end
        end

        status_bar.clear do
          flow(width: 1.0, max_width: 720, h_align: :center) do
            label "Current Configuration: "
            @config_label = label window.backend.settings.config
          end
        end

        body.clear do
          @configs_list = stack width: 1.0, height: 1.0, margin_top: 36, max_width: 720, h_align: :center, scroll: true do
          end
        end

        populate_configs
      end

      def populate_configs
        @config_files = Dir.glob("#{TAC::CONFIGS_PATH}/*.json")
        @config_files_list = @config_files.map { |file| Dialog::NamePromptDialog::NameStub.new(File.basename(file, ".json")) }

        @configs_list.clear do
          @config_files.sort_by { |f| [f.downcase] }.each_with_index do |config_file, i|
            flow width: 1.0, height: 36, **THEME_ITEM_CONTAINER_PADDING do
              name = File.basename(config_file, ".json")

              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR unless name == window.backend.settings.config
              background THEME_HIGHLIGHTED_COLOR if name == window.backend.settings.config

              button "#{name}", fill: true, text_size: THEME_ICON_SIZE - 3 do
                change_config(name)

                if window.backend.tacnet.connected?
                  window.backend.tacnet.puts(TAC::TACNET::PacketHandler.packet_select_config(name))
                end
              end

              button get_image("#{TAC::MEDIA_PATH}/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Rename configuration" do
                push_state(Dialog::NamePromptDialog, title: "Rename Config", renaming: @config_files_list.find { |c| c.name == name }, list: @config_files_list, accept_label: "Update", callback_method: proc { |old_name, new_name|
                  if not File.exist?("#{TAC::CONFIGS_PATH}/#{new_name}.json")
                    FileUtils.mv(
                      "#{TAC::CONFIGS_PATH}/#{name}.json",
                      "#{TAC::CONFIGS_PATH}/#{new_name}.json"
                      )

                    if window.backend.settings.config == name
                      change_config(new_name)
                    end

                    populate_configs
                  else
                    push_state(Dialog::AlertDialog, title: "Config Rename Failed", message: "File already exists at #{TAC::CONFIGS_PATH}/#{new_name}.json}")
                  end
                })
              end

              button get_image("#{TAC::MEDIA_PATH}/icons/trashcan.png"), image_width: THEME_ICON_SIZE, **THEME_DANGER_BUTTON, tip: "Delete configuration" do
                push_state(Dialog::ConfirmDialog, title: "Delete Config?", dangerous: true, callback_method: proc {
                  File.delete("#{TAC::CONFIGS_PATH}/#{name}.json")

                  if window.backend.settings.config == name
                    change_config("")
                  end

                  if window.backend.tacnet.connected?
                    window.backend.tacnet.puts(TAC::TACNET::PacketHandler.packet_delete_config(name))
                  end

                  populate_configs
                })
              end
            end
          end
        end
      end

      def change_config(name)
        window.backend.settings.config = name
        window.backend.save_settings
        window.backend.load_config(name)

        @config_label.value = name.to_s

        populate_configs
      end
    end
  end
end