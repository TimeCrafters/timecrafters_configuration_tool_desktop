module TAC
  class TACNET
    DEFAULT_HOSTNAME = "192.168.49.1"
    DEFAULT_PORT = 8962

    SYNC_INTERVAL = 250 # ms
    HEARTBEAT_INTERVAL = 1_500 # ms

    def initialize
      @connection = nil
    end

    def connect(hostname = DEFAULT_HOSTNAME, port = DEFAULT_PORT)
      return if @connection && @connection.connected?

      @connection = Connection.new(hostname, port)
      @connection.connect
    end

    def status
      if connected?
        :connected
      elsif @connection && !@connection.client.socket_error?
        :connecting
      elsif @connection && @connection.client.socket_error?
        :connection_error
      else
        :not_connected
      end
    end

    def full_status
      _status = status.to_s.split("_").map { |c| c.capitalize }.join(" ")

      if connected?
        net_stats = ""
        net_stats += "<b>Connection Statistics:</b>\n"
        net_stats += "<b>Packets Sent:</b> #{client.packets_sent}\n"
        net_stats += "<b>Packets Received:</b> #{client.packets_received}\n\n"
        net_stats += "<b>Data Sent:</b> #{client.data_sent} bytes\n"
        net_stats += "<b>Data Received:</b> #{client.data_received} bytes\n"

        "<b>Status:</b> #{_status}\n\n#{net_stats}"
      elsif @connection&.client && @connection.client.socket_error?
        "<b>Status:</b> #{_status}\n\n#{@connection.client.last_socket_error.to_s}"
      else
        "<b>Status:</b> #{_status}"
      end
    end

    def connected?
      @connection&.connected?
    end

    def close
      if connected?
        @connection.close
        @connection = nil
      end
    end

    def client
      @connection.client
    end

    def puts(packet)
      @connection.puts(packet) if connected?
    end

    def gets
      @connection.gets if connected?
    end

    def self.milliseconds
      Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
    end
  end
end