module TAC
  class Backend
    attr_reader :config, :settings, :tacnet
    def initialize
      @config = load_config
      @settings = load_settings
      @tacnet = TACNET.new

      @config_changed = false
      @settings_changed = false
    end

    def config_changed!
      @config.configuration.updated_at = Time.now
      @config_changed = true
    end

    def config_changed?
      @config_changed
    end

    def load_config
      if File.exist?(TAC::CONFIG_PATH)
        return TAC::Config.new
      else
        write_default_config
        load_config
      end
    end

    def update_config
      @config = load_config
      $window.current_state.populate_groups_list
    end

    def save_config
      json = @config.to_json

      File.open(TAC::CONFIG_PATH, "w") { |f| f.write json }

      @config_changed = false
    end

    def upload_config
      if @tacnet.connected?
        json = @config.to_json
        @tacnet.puts(TAC::TACNET::PacketHandler.packet_upload_config(json))
      end
    end

    def download_config
      if @tacnet.connected?
        @tacnet.puts(TAC::TACNET::PacketHandler.packet_download_config)
      end
    end

    def write_default_config
      File.open(TAC::CONFIG_PATH, "w") do |f|
        f.write JSON.dump(
          {
            config: {
              created_at: Time.now,
              updated_at: Time.now,
              spec_version: TAC::CONFIG_SPEC_VERSION,
              hostname: TACNET::DEFAULT_HOSTNAME,
              port: TACNET::DEFAULT_PORT,
              presets: [],
            },
            data: {
              groups: [],
            },
          }
        )
      end
    end

    def refresh_config
      load_config

      $window.states.clear
      $window.push_state(Editor)
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
        return TAC::Settings.new
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
            }
          }
        )
      end
    end
  end
end