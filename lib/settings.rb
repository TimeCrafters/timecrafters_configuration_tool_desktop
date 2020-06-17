module TAC
  class Settings
    attr_accessor :hostname, :port, :config
    def initialize
      parse(File.read(TAC::SETTINGS_PATH))
    end

    def parse(json)
      data = JSON.parse(json, symbolize_names: true)

      @hostname = data[:data][:hostname]
      @port = data[:data][:port]
      @config = data[:data][:config]
    end

    def to_json(*args)
      {
        data: {
          hostname: @hostname,
          port: @port,
          config: @config,
        }
      }.to_json(*args)
    end
  end
end