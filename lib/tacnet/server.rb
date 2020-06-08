module TAC
  class TACNET
    class Server
      TAG = "TACNET|Server"
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

      def start(run_on_main_thread: false)
        thread = Thread.new do
          while (!@socket && @connection_attempts < @max_connection_attempts)
            begin
              log.i(TAG, "Starting server...")
              @socket = TCPServer.new(@port)
            rescue => error
              log.e(TAG, error)

              @connection_attempts += 1
              retry if @connection_attempts < @max_connection_attempts
            end
          end

          while @socket && !@socket.closed?
            begin
              run_server
            rescue => error
              p error
              @socket.close if @socket
            end
          end
        end

        thread.join if run_on_main_thread
      end

      def run_server
        while !@socket.closed?
          client = Client.new
          client.sync_interval = @sync_interval
          client.socket = @socket.accept

          if @active_client && @active_client.connected?
            log.i(TAG, "Too many clients, already have one connected!")
            client.close("Too many clients!")
            pp @active_client.connected?
          else
            @active_client = client
            # TODO: Backup local config
            # SEND CONFIG
            config = File.read(TAC::CONFIG_PATH)

            @active_client.puts(PacketHandler.packet_handshake(@active_client.uuid))
            @active_client.puts(PacketHandler.packet_dump_config(config))

            log.i(TAG, "Client connected!")

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

          if message && !message.empty?
            @packet_handler.handle(message)
          end

          if Gosu.milliseconds > @last_heartbeat_sent + @heartbeat_interval
            @last_heartbeat_sent = Gosu.milliseconds

            @active_client.puts(PacketHandler.packet_heartbeat)
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