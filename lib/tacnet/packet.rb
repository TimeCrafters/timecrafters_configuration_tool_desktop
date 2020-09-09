module TAC
  class TACNET
    class Packet
      PROTOCOL_VERSION = 1
      PROTOCOL_SEPERATOR = "|"
      PROTOCOL_HEARTBEAT = "heartbeat"

      PACKET_TYPES = {
        handshake: 0,
        heartbeat: 1,
        error: 2,

        download_config: 10,
        upload_config: 11,
        list_configs: 12,
        select_config: 13,
        add_config: 14,
        update_config: 15,
        delete_config: 16,

        add_group: 20,
        update_group: 21,
        delete_group: 22,

        add_action: 30,
        update_action: 31,
        delete_action: 32,

        add_variable: 40,
        update_variable: 41,
        delete_variable: 42,
      }

      def self.from_stream(message)
        slice = message.split("|", 4)

        if slice.size < 4
          warn "Failed to split packet along first 4 " + PROTOCOL_SEPERATOR + ". Raw return: " + slice.to_s
          return nil
        end

        if slice.first != PROTOCOL_VERSION.to_s
          warn "Incompatible protocol version received, expected: " + PROTOCOL_VERSION.to_s + " got: " + slice.first
          return nil
        end

        unless valid_packet_type?(Integer(slice[1]))
          warn "Unknown packet type detected: #{slice[1]}"
          return nil
        end

        protocol_version = Integer(slice[0])
        type = PACKET_TYPES.key(Integer(slice[1]))
        content_length = Integer(slice[2])
        body = slice[3]

        raise "Type is #{type.inspect} [#{type.class}]" unless type.is_a?(Symbol)

        return Packet.new(protocol_version, type, content_length, body)
      end

      def self.create(packet_type, body)
        Packet.new(PROTOCOL_VERSION, PACKET_TYPES.key(packet_type), body.length, body)
      end

      def self.valid_packet_type?(packet_type)
        PACKET_TYPES.values.find { |t| t == packet_type }
      end

      attr_reader :protocol_version, :type, :content_length, :body
      def initialize(protocol_version, type, content_length, body)
        @protocol_version = protocol_version
        @type = type
        @content_length = content_length
        @body = body
      end

      def encode_header
        string = ""
        string += protocol_version.to_s
        string += PROTOCOL_SEPERATOR
        string += PACKET_TYPES[type].to_s
        string += PROTOCOL_SEPERATOR
        string += content_length.to_s
        string += PROTOCOL_SEPERATOR

        return string
      end

      def valid?
        true
      end

      def to_s
        "#{encode_header}#{body}"
      end
    end
  end
end