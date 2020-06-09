module TAC
  class Backend
    attr_reader :config, :tacnet
    def initialize
      @config = load_config
      @tacnet = TACNET.new

      @config_changed = false
    end

    def config_changed!
      @config.config.updated_at = Time.now
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
  end
end