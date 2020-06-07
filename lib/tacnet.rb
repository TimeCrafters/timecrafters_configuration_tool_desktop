module TAC
  class TACNET
    DEFAULT_HOSTNAME = "192.168.49.1"
    DEFAULT_PORT = 8962

    SYNC_INTERVAL = 250 # ms
    HEARTBEAT_INTERVAL = 1_500 # ms

    def initialize
      @connection = nil
      @server = nil
    end

    def connect(hostname = DEFAULT_HOSTNAME, port = DEFAULT_PORT, error_callback = proc {})
      return if @connection && @connect.connected?

      @connection = Connection.new(hostname, port)
      puts "Connecting..."
      @connection.connect(error_callback)
    end
  end
end