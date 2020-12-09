module TAC
  class Pages
    class Configurations < Page
      def setup
        header_bar("Manage Configurations")

        menu_bar.clear do
          button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_height: 1.0, tip: "Add configuration" do
            push_state(Dialog::NamePromptDialog, title: "Config Name", callback_method: proc { |name|
              window.backend.write_new_config(name)

              change_config(name)
              populate_configs
            })
          end

          # label "Manage Configurations", text_size: 36
        end

        status_bar.clear do
          label "Current Configuration: "
          @config_label = label window.backend.settings.config
        end

        body.clear do
          @configs_list = stack width: 1.0 do
          end
        end

        populate_configs
      end

      def populate_configs
        @config_files = Dir.glob("#{TAC::CONFIGS_PATH}/*.json")
        @config_files_list = @config_files.map { |file| Dialog::NamePromptDialog::NameStub.new(File.basename(file, ".json")) }

        @configs_list.clear do
          @config_files.each_with_index do |config_file, i|
            flow width: 1.0, **THEME_ITEM_CONTAINER_PADDING do
              background i.even? ? THEME_EVEN_COLOR : THEME_ODD_COLOR

              name = File.basename(config_file, ".json")

              button "#{name}", width: 0.94 do
                change_config(name)
              end

              button get_image("#{TAC::ROOT_PATH}/media/icons/gear.png"), image_width: THEME_ICON_SIZE, tip: "Rename configuration" do
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
                    push_state(Dialog::AlertDialog, title: "Config Rename Failed", message: "File already exists at\n#{TAC::CONFIGS_PATH}/#{new_name}.json}")
                  end
                })
              end

              button get_image("#{TAC::ROOT_PATH}/media/icons/trashcan.png"), image_width: THEME_ICON_SIZE, **THEME_DANGER_BUTTON, tip: "Delete configuration" do
                push_state(Dialog::ConfirmDialog, title: "Delete Config?", callback_method: proc {
                  File.delete("#{TAC::CONFIGS_PATH}/#{name}.json")

                  if window.backend.settings.config == name
                    change_config(nil)
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
      end
    end
  end
end