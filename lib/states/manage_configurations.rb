module TAC
  class States
    class ManageConfigurations < CyberarmEngine::GuiState
      def setup
        theme(THEME)
        stack width: 1.0, height: 0.1 do
          background THEME_HEADER_BACKGROUND
          label "#{TAC::NAME} ― Manage Configurations", bold: true, text_size: THEME_HEADING_TEXT_SIZE
          flow do
            button "Close" do
              if window.backend.settings.config
                window.backend.load_config(window.backend.settings.config)

                pop_state

                window.current_state.refresh_config
              else
                push_state(Dialog::AlertDialog, title: "No Config Loaded", message: "A config must be loaded.")
              end
            end

            label "Current Configuration: "
            @config_label = label window.backend.settings.config
          end
        end

        stack width: 1.0, height: 0.9 do
          background THEME_CONTENT_BACKGROUND
          flow do
            label "Configurations", text_size: THEME_SUBHEADING_TEXT_SIZE
            button get_image("#{TAC::ROOT_PATH}/media/icons/plus.png"), image_width: 18, tip: "Add configuration" do
              push_state(Dialog::NamePromptDialog, title: "Config Name", callback_method: proc { |name|
                window.backend.write_new_config(name)

                change_config(name)
                populate_configs
              })
            end
          end

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

        @config_label.value = name.to_s
      end
    end
  end
end