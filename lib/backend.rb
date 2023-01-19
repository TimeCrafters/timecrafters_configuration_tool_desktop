module TAC
  class Backend
    attr_reader :config, :settings, :tacnet
    def initialize
      load_settings
      load_config(@settings.config) if @settings.config && File.exist?("#{TAC::CONFIGS_PATH}/#{@settings.config}.json")
      @tacnet = TACNET.new

      @config_changed = false
      @settings_changed = false
    end

    def config_changed!
      @config.configuration.updated_at = Time.now
      @config.configuration.revision += 1
      @config_changed = true

      save_config

      if @tacnet.connected?
        upload_config(@config.name)
      end
    end

    def config_changed?
      @config_changed
    end

    def load_config(name)
      if File.exist?("#{TAC::CONFIGS_PATH}/#{name}.json")
        @config = TAC::Config.new(name)
      end
    end

    def save_config(name = nil, json = nil)
      name = @config.name unless name
      json = @config.to_json unless name && json

      File.open("#{TAC::CONFIGS_PATH}/#{name}.json", "w") { |f| f.write json }

      @config_changed = false
    end

    def move_config(old_name, new_name)
      if not File.exist?("#{TAC::CONFIGS_PATH}/#{old_name}.json") or
        File.directory?("#{TAC::CONFIGS_PATH}/#{old_name}.json")
        # move_config: Can not move config file "#{old_name}" does not exist!
        return false
      end

      if File.exist?("#{TAC::CONFIGS_PATH}/#{new_name}.json") &&
        !File.directory?("#{TAC::CONFIGS_PATH}/#{old_name}.json")
        # move_config: Config file "#{new_name}" already exist!
        return false
      end

      return FileUtils.mv(
        "#{TAC::CONFIGS_PATH}/#{old_name}.json",
        "#{TAC::CONFIGS_PATH}/#{new_name}.json"
      )
    end

    def delete_config(config_name)
      FileUtils.rm("#{TAC::CONFIGS_PATH}/#{config_name}.json") if File.exist?("#{TAC::CONFIGS_PATH}/#{config_name}.json")
    end


    def upload_config(config_name)
      if @tacnet.connected?
        json = Config.new(config_name).to_json
        @tacnet.puts( TAC::TACNET::PacketHandler.packet_upload_config(config_name, json) )
      end
    end

    def download_config(config_name)
      if @tacnet.connected?
        @tacnet.puts( TAC::TACNET::PacketHandler.packet_download_config(config_name) )
      end
    end

    def write_new_config(name)
      File.open("#{TAC::CONFIGS_PATH}/#{name}.json", "w") do |f|
        f.write JSON.dump(
          {
            config: {
              created_at: Time.now,
              updated_at: Time.now,
              spec_version: TAC::CONFIG_SPEC_VERSION,
              revision: 0,
            },
            data: {
              groups: [],
              presets: {
                groups: [],
                actions: [],
              },
            },
          }
        )
      end
    end

    def refresh_tacnet_status
      CyberarmEngine::Window.instance.current_state.refresh_tacnet_status
    end


    def settings_changed!
      @settings_changed = true
    end

    def settings_changed?
      @settings_changed
    end

    def load_settings
      if File.exist?(TAC::SETTINGS_PATH)
        @settings = TAC::Settings.new
      else
        write_default_settings
        load_settings
      end
    end

    def save_settings
      json = @settings.to_json

      File.open(TAC::SETTINGS_PATH, "w") { |f| f.write json }

      @settings_changed = false
    end

    def write_default_settings
      File.open(TAC::SETTINGS_PATH, "w") do |f|
        f.write JSON.dump(
          {
            data: {
              hostname: TACNET::DEFAULT_HOSTNAME,
              port: TACNET::DEFAULT_PORT,
              config: "",
            }
          }
        )
      end
    end
  end
end
