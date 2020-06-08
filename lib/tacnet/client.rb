module TAC
  class TACNET
    class Client
      TAG = "TACNET|Client"
      CHUNK_SIZE = 4096

      attr_reader :uuid, :read_queue, :write_queue, :socket,
                  :packets_sent, :packets_received,
                  :data_sent, :data_received
      attr_accessor :sync_interval
      def initialize
        @uuid = SecureRandom.uuid
        @read_queue = []
        @write_queue = []

        @sync_interval = 100

        @packets_sent, @packets_received = 0, 0
        @data_sent, @data_received = 0, 0
      end

      def socket=(socket)
        @socket = socket

        listen
      end

      def listen
        Thread.new do
          while connected?
            # Read from socket
            while message_in = read
              if message_in.empty?
                break
              else
                log.i(TAG, "Read: " + message_in)

                @read_queue << message_in

                @packets_received += 1
                @data_received += message_in.length
              end
            end

            sleep @sync_interval / 1000.0
          end
        end

        Thread.new do
          while connected?
            # Write to socket
            while message_out = @write_queue.shift
              write(message_out)

              @packets_sent += 1
              @data_sent += message_out.to_s.length
              log.i(TAG, "Write: " + message_out.to_s)
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

          log.i(TAG, "Writing to Queue: " + message)

          message = gets
        end
      end

      def connected?
        !closed?
      end

      def bound?
        @socket.bound? if @socket
      end

      def closed?
        @socket.closed? if @socket
      end

      def write(message)
        begin
          @socket.puts("#{message}\r\n\n")
        rescue Errno::EPIPE, IOError => error
          log.e(TAG, error.message)
          close
        end
      end

      def read
        message = ""

        begin
          data = @socket.readpartial(CHUNK_SIZE)
          message += data
        rescue Errno::EPIPE, EOFError
          message = ""
          break
        end until message.end_with?("\r\n\n")


        return message.strip
      end

      def puts(message)
        @write_queue << message
      end

      def gets
        @read_queue.shift
      end

      def encode(message)
        return message
      end

      def decode(blob)
        return blob
      end

      def flush
        @socket.flush if socket
      end

      def close(reason = nil)
        write(reason) if reason
        @socket.close if @socket
      end
    end
  end
end