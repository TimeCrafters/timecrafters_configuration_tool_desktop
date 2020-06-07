module TAC
  class Backend
    attr_reader :config, :tacnet
    def initialize
      @config = load_config
      @tacnet = TACNET.new
    end

    def load_config
      if File.exist?(TAC::CONFIG_PATH)
        JSON.parse(File.read( TAC::CONFIG_PATH ))
      else
        write_default_config
        load_config
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