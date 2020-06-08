module TAC
  class TACNET
    class Connection
      TAG = "TACNET|Connection"
      attr_reader :client
      def initialize(hostname = DEFAULT_HOSTNAME, port = DEFAULT_PORT)
        @hostname = hostname
        @port = port

        @client = nil

        @last_sync_time = Gosu.milliseconds
        @sync_interval = SYNC_INTERVAL

        @last_heartbeat_sent = Gosu.milliseconds
        @heartbeat_interval = HEARTBEAT_INTERVAL

        @connection_handler = proc do
          handle_connection
        end

        @packet_handler = PacketHandler.new(host_is_a_connection: true)
      end

      def connect
        return if @client

        @client = Client.new

        Thread.new do
          begin
            @client.socket = Socket.tcp(@hostname, @port, connect_timeout: 5)
            log.i(TAG, "Connected to: #{@hostname}:#{@port}")

            while @client && @client.connected?
              if Gosu.milliseconds > @last_sync_time + @sync_interval
                @last_sync_time = Gosu.milliseconds

                @client.sync(@connection_handler)
              end
            end

          rescue => error
            log.e(TAG, error)

            if @client
              @client.close
              @client.last_socket_error = error
              @client.socket_error = true
            end
          end
        end
      end

      def handle_connection
        if @client && @client.connected?
          message = @client.gets

          @packet_handler.handle(message) if message

          if Gosu.milliseconds > @last_heartbeat_sent + @heartbeat_interval
            @last_heartbeat_sent = Gosu.milliseconds

            @client.puts(PacketHandler.packet_heartbeat)
          end

          sleep @sync_interval / 1000.0
        end
      end

      def puts(packet)
        @client.puts(packet)
      end

      def gets
        @client.gets
      end

      def connected?
        @client.connected? if @client
      end

      def closed?
        @client.closed? if @client
      end

      def close
        @client.close if @client
      end
    end
  end
end