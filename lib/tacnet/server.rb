module TAC
  class TACNET
    class Server
      attr_reader :active_client,
                  :packets_sent, :packets_received, :data_sent, :data_received,
                  :client_last_packets_sent, :client_last_packets_received, :client_last_data_sent, :client_last_data_received
      def initialize(port = DEFAULT_PORT)
        @port = port

        @socket = nil
        @active_client = nil
        @connection_attempts = 0
        @max_connection_attempts = 10

        @packets_sent, @packets_received, @client_last_packets_sent, @client_last_packets_received = 0, 0, 0, 0
        @data_sent, @data_received, @client_last_data_sent, @client_last_data_received = 0, 0, 0, 0

        @last_sync_time = 0
        @sync_interval = SYNC_INTERVAL

        @last_heartbeat_sent = 0
        @heartbeat_interval = HEARTBEAT_INTERVAL

        @client_handler_proc = proc do
          handle_client
        end

        @packet_handler = PacketHandler.new
      end

      def start
        Thread.new do
          while !@socket && @connection_attempts < @max_connection_attempts
            begin
              @socket = TCPServer.new(@port)
            rescue => error
              p error

              @connection_attempts += 1
              retry
            end
          end

          while !@socket.closed?
            begin
              run_server
            rescue => error
              p error
              @socket.close
            end
          end
        end
      end

      def run_server
        while !@socket.closed?
          client = Client.new
          client.sync_interval = @sync_interval
          client.socket = @socket.accept

          unless @active_client && @active_client.closed?
            warn "Too many clients, already have one connected!"
            client.close("Too many clients!")
          else
            @active_client = client
            # TODO: Backup local config
            # SEND CONFIG
            config = File.read(TAC::CONFIG_PATH)

            @active_client.puts(PacketHandler.packet_handshake(@active_client.uuid))
            @active_client.puts(PacketHandler.packet_dump_config(config))

            Thread.new do
              while @active_client && @active_client.connected?
                if Gosu.milliseconds > @last_sync_time + @sync_interval
                  @last_sync_time = Gosu.milliseconds

                  @active_client.sync(@client_handler_proc)
                  update_stats
                end
              end

              update_stats
              @active_client = nil

              @client_last_packets_sent = 0
              @client_last_packets_received = 0
              @client_last_data_sent = 0
              @client_last_data_received = 0
            end
          end
        end
      end

      def handle_client
        if @active_client && @active_client.connected?
          message = @active_client.gets

          unless message.empty?
            @packet_handler.handle(message)
          end

          if Gosu.milliseconds > @last_heartbeat_sent + @heartbeat_interval
            @last_heartbeat_sent = Gosu.milliseconds

            @active_client.puts(PacketHandler.packet_heartbeart)
          end
        end
      end

      private def update_stats
        if @active_client
          # NOTE: Sent and Received are reversed for Server stats

          @packets_sent += @active_client.packets_received - @client_last_packets_received
          @packets_received += @active_client.packets_sent - @client_last_packets_sent

          @data_sent += @active_client.data_received - @client_last_data_received
          @data_received += @active_client.data_sent - @client_last_data_sent

          @client_last_packets_sent = @active_client.packets_sent
          @client_last_packets_received = @active_client.packets_received
          @client_last_data_sent = @active_client.data_sent
          @client_last_data_received = @active_client.data_received
        end
      end
    end
  end
end