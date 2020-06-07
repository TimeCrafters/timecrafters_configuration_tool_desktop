module TAC
  class TACNET
    class PacketHandler
      def initialize(host_is_a_connection: false)
        @host_is_a_connection = host_is_a_connection
      end

      def handle(message)
        packet = Packet.from_stream(message)

        if packet
          hand_off(packet)
        else
          warn "Rejected raw packet: #{message}"
        end
      end

      def hand_off(packet)
        case packet.type
        when :handshake
          handle_handshake(packet)
        when :heartbeat
          handle_heartbeat(packet)
        when :dump_config
          handle_dump_config(packet)
        else
          warn "No hand off available for packet type: #{packet.type}"
        end
      end

      def handle_handshake(packet)
      end

      def handle_heartbeat(packet)
      end

      def handle_dump_config(packet)
        begin
          hash = JSON.parse(packet.body)

          if @host_is_a_connection
            File.open("#{TAC::ROOT_PATH}/data/config.json", "w") { |f| f.write packet.body }

            $window.backend.update_config
          end
        rescue JSON::ParserError
        end
      end

      def self.packet_handshake(client_uuid)
        Packet.create(Packet::PACKET_TYPES[:handshake], client_uuid)
      end

      def self.packet_heartbeat
        Packet.create(Packet::PACKET_TYPES[:heartbeat], Packet::PROTOCOL_VERSION)
      end

      def self.packet_dump_config(string)
        string = string.gsub("\n", " ")

        Packet.create(Packet::PACKET_TYPES[:dump_config], string)
      end
    end
  end
end