module TAC
  class Backend
    attr_reader :config, :tacnet
    def initialize
      @config = load_config
      @tacnet = TACNET.new
    end

    def load_config
      if File.exist?(TAC::CONFIG_PATH)
        return JSON.parse(File.read( TAC::CONFIG_PATH ), symbolize_names: true)
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
      json = JSON.dump(@config)

      File.open(TAC::CONFIG_PATH, "w") { |f| f.write json }

      if @tacnet.connected?
        @tacnet.puts(TAC::TACNET::PacketHandler.packet_dump_config(json))
      end
    end

    def write_default_config
      File.open(TAC::CONFIG_PATH, "w") do |f|
        f.write JSON.dump(
          {
            config: {
              spec_version: TAC::CONFIG_SPEC_VERSION,
              hostname: TACNET::DEFAULT_HOSTNAME,
              port: TACNET::DEFAULT_PORT,
              presets: [],
            },
            data: {
              groups: [],
              actions: [],
              values: [],
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