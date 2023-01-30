module TAC
  class TACNET
    class Client
      TAG = "TACNET|Client"
      CHUNK_SIZE = 4096
      PACKET_TAIL = "\r\n\n"

      attr_reader :uuid, :read_queue, :write_queue, :socket,
                  :packets_sent, :packets_received,
                  :data_sent, :data_received

      attr_accessor :sync_interval, :last_socket_error, :socket_error

      def initialize
        @uuid = SecureRandom.uuid
        @read_queue = []
        @write_queue = []

        @sync_interval = 100

        @last_socket_error = nil
        @socket_error = false
        @bound = false

        @packets_sent = 0
        @packets_received = 0

        @data_sent = 0
        @data_received = 0
      end

      def uuid=(id)
        @uuid = id
      end

      def socket=(socket)
        @socket = socket
        @bound = true

        listen
      end

      def listen
        Thread.new do
          while connected?
            # Read from socket
            while (message_in = read)
              break if message_in.empty?

              log.i(TAG, "Read: #{message_in}")

              @read_queue << message_in

              @packets_received += 1
              @data_received += message_in.length
            end

            sleep @sync_interval / 1000.0
          end
        end

        Thread.new do
          while connected?
            # Write to socket
            while (message_out = @write_queue.shift)
              write(message_out)

              @packets_sent += 1
              @data_sent += message_out.to_s.length
              log.i(TAG, "Write: #{message_out}")
            end

            sleep @sync_interval / 1000.0
          end
        end
      end

      def sync(block)
        block.call
      end

      def handle_read_queue
        message = gets

        while message
          puts(message)

          log.i(TAG, "Writing to Queue: #{message}")

          message = gets
        end
      end

      def socket_error?
        @socket_error
      end

      def connected?
        if closed? == true || closed? == nil
          false
        else
          true
        end
      end

      def closed?
        @socket&.closed?
      end

      def write(message)
        @socket.puts("#{message}#{PACKET_TAIL}") if connected?
      rescue => error
        @last_socket_error = error
        @socket_error = true

        log.e(TAG, error.message)

        close
      end

      def read
        @socket&.gets&.strip if connected?
      rescue => error
        @last_socket_error = error
        @socket_error = true

        log.e(TAG, error.message)

        close
      end

      def puts(message)
        @write_queue << message
      end

      def gets
        @read_queue.shift
      end

      def encode(message)
        message
      end

      def decode(blob)
        blob
      end

      def flush
        @socket.flush if socket
      end

      def close(reason = nil)
        write(reason) if reason

        @socket&.close
      end
    end
  end
end
