module TAC
  class Backend
    attr_reader :config, :settings, :tacnet
    def initialize
      load_settings
      load_config(@settings.config) if @settings.config
      @tacnet = TACNET.new

      @config_changed = false
      @settings_changed = false
    end

    def config_changed!
      @config.configuration.updated_at = Time.now
      @config.configuration.revision += 1
      @config_changed = true
    end

    def config_changed?
      @config_changed
    end

    def load_config(name)
      if File.exist?("#{TAC::CONFIGS_PATH}/#{name}.json")
        @config = TAC::Config.new(name)
      end
    end

    def save_config(name)
      json = @config.to_json

      File.open("#{TAC::CONFIGS_PATH}/#{name}.json", "w") { |f| f.write json }

      @config_changed = false
    end

    def upload_config
      if @config && @tacnet.connected?
        json = @config.to_json
        @tacnet.puts(TAC::TACNET::PacketHandler.packet_upload_config(json))
      end
    end

    def download_config
      if @config && @tacnet.connected?
        @tacnet.puts(TAC::TACNET::PacketHandler.packet_download_config)
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
              hostname: TACNET::DEFAULT_HOSTNAME,
              port: TACNET::DEFAULT_PORT,
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
      $window.current_state.refresh_tacnet_status
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
              config: nil,
            }
          }
        )
      end
    end
  end
end