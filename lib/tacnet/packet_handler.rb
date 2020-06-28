module TAC
  class TACNET
    class PacketHandler
      TAG = "TACNET|PacketHandler"
      def initialize(host_is_a_connection: false)
        @host_is_a_connection = host_is_a_connection
      end

      def handle(message)
        packet = Packet.from_stream(message)

        if packet
          hand_off(packet)
        else
          log.d(TAG, "Rejected raw packet: #{message}")
        end
      end

      def hand_off(packet)
        case packet.type
        when :handshake
          handle_handshake(packet)
        when :heartbeat
          handle_heartbeat(packet)
        when :error
          handle_error(packet)
        when :download_config
          handle_download_config(packet)
        when :upload_config
          handle_upload_config(packet)
        else
          log.d(TAG, "No hand off available for packet type: #{packet.type}")
        end
      end

      def handle_handshake(packet)
        if @host_is_a_connection
          $window.backend.tacnet.client.uuid = packet.body
        end
      end

      # TODO: Reset socket timeout
      def handle_heartbeat(packet)
      end

      # TODO: Handle errors
      def handle_error(packet)
      end

      def handle_upload_config(packet)
        begin
          config_name, json = packet.body.split(Packet::PROTOCOL_HEADER_SEPERATOR)
          data = JSON.parse(json, symbolize_names: true)

          if @host_is_a_connection
            if data.is_a?(Array)
              # OLDEST CONFIG, upgrade?
              $window.push_state(TAC::Dialog::AlertDialog, title: "Invalid Config", message: "Remote config to old.")

            elsif data.is_a?(Hash) && data.dig(:config, :spec_version) == TAC::CONFIG_SPEC_VERSION
              $window.push_state(TAC::Dialog::ConfirmDialog, title: "Replace Config", message: "Replace local config\nwith remote config?", callback_method: proc {
                File.open("#{TAC::CONFIGS_PATH}/#{config_name}.json", "w") { |f| f.write json }

                $window.backend.load_config(config_name)
              })

            elsif data.is_a?(Hash) && data.dig(:config, :spec_version) < TAC::CONFIG_SPEC_VERSION
              # OLD CONFIG, Upgrade?
              $window.push_state(TAC::Dialog::ConfirmDialog, title: "Upgrade Config", message: "Remote config is an older\nspec version.\nTry to upgrade?", callback_method: proc {})

            elsif data.is_a?(Hash) && data.dig(:config, :spec_version) > TAC::CONFIG_SPEC_VERSION
              # NEWER CONFIG, Error Out
              $window.push_state(TAC::Dialog::AlertDialog, title: "Invalid Config", message: "Client outdated, check for\nupdates.\nSupported config spec:\nv#{TAC::CONFIG_SPEC_VERSION} got v#{data.dig(:config, :spec_version)}")

            else
              # CONFIG is unknown
              $window.push_state(TAC::Dialog::AlertDialog, title: "Invalid Config", message: "Remote config is not supported.")
            end
          end
        rescue JSON::ParserError => e
          log.e(TAG, "JSON parsing error: #{e}")
        end
      end

      def handle_download_config(packet)
        if @host_is_a_connection
          json = JSON.dump($window.backend.config)
          config = $window.backend.settings.config

          $window.backend.tacnet.puts(PacketHandler.packet_upload_config(config, json))
        else
          if $server.active_client && $server.active_client.connected?
            settings = TAC::Settings.new

            if File.exist?("#{TAC::CONFIGS_PATH}/#{settings.config}.json")
              json = File.read("#{TAC::CONFIGS_PATH}/#{settings.config}.json")

              $server.active_client.puts(PacketHandler.packet_upload_config(settings.config, json))
            else
              $server.active_client.puts(PacketHandler.packet_error("NO_SUCH_CONFIG", "No config named #{settings.config}"))
            end
          end
        end
      end

      def self.packet_handshake(client_uuid)
        Packet.create(Packet::PACKET_TYPES[:handshake], client_uuid)
      end

      def self.packet_heartbeat
        Packet.create(Packet::PACKET_TYPES[:heartbeat], Packet::PROTOCOL_HEARTBEAT)
      end

      def self.packet_error(error_code, message)
        Packet.create(Packet::PACKET_TYPES[:error], error_code.to_s, message.to_s)
      end

      def self.packet_download_config(config_name)
        Packet.create(Packet::PACKET_TYPES[:download_config], "#{config_name}")
      end

      def self.packet_upload_config(config_name, json)
        string = "#{config_name}#{Packet::PROTOCOL_HEADER_SEPERATOR}#{json.gsub("\n", " ")}"

        Packet.create(Packet::PACKET_TYPES[:upload_config], string)
      end
    end
  end
end