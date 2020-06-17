module TAC
  class Settings
    attr_accessor :hostname, :port
    def initialize
      parse(File.read(TAC::SETTINGS_PATH))
    end

    def parse(json)
      data = JSON.parse(json, symbolize_names: true)

      @hostname = data[:data][:hostname]
      @port = data[:data][:port]
    end

    def to_json(*args)
      {
        data: {
          hostname: @hostname,
          port: @port,
        }
      }.to_json(*args)
    end
  end
end