module TAC
  class TACNET
    DEFAULT_HOSTNAME = "192.168.49.1"
    DEFAULT_PORT = 8962

    SYNC_INTERVAL = 250 # ms
    HEARTBEAT_INTERVAL = 1_500 # ms

    def initialize
      @connection = nil
    end

    def connect(hostname = DEFAULT_HOSTNAME, port = DEFAULT_PORT, error_callback = proc {})
      return if @connection && @connection.connected?

      @connection = Connection.new(hostname, port)
      @connection.connect(error_callback)
    end

    def connected?
      @connection && @connection.connected?
    end

    def client
      if connected?
        @connection.client
      end
    end

    def puts(packet)
      if connected?
        @connection.puts(packet)
      end
    end

    def gets
      if connected?
        @connection.gets
      end
    end
  end
end