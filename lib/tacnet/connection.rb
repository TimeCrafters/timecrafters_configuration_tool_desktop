module TAC
  class TACNET
    class Connection
      def initialize(hostname = DEFAULT_HOSTNAME, port = DEFAULT_PORT)
        @hostname = hostname
        @port = port

        @last_sync_time = 0
        @sync_interval = SYNC_INTERVAL

        @last_heartbeat_sent = 0
        @heartbeat_interval = HEARTBEAT_INTERVAL

        @connection_handler = proc do
          handle_connection
        end
      end

      def connect(error_callback)
        return if @client

        @client = Client.new

        Thread.new do
          begin
            @client.socket = Socket.tcp(@hostname, @port, connect_timeout: 5)

            while @client && @client.connected?
              if Gosu.milliseconds > @last_sync_time + @sync_interval
                @last_sync_time = Gosu.milliseconds

                @client.sync(@connection_handler)
              end
            end

          rescue => error
            p error
            error_callback.call(error)
          end
        end
      end

      def handle_connection
        if @client && @client.connected?
          message = @client.gets

          PacketHandler.handle(message) if message

          if Gosu.milliseconds > @last_heartbeat_sent + @heartbeat_interval
            last_heartbeat_sent = Gosu.milliseconds

            client.puts(PacketHandler.packet_heartbeat)
          end
        end
      end
    end
  end
end