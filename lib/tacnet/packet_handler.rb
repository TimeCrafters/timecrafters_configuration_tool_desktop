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
          log.i(TAG, "Received packet of type: #{packet.type}")
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
        when :list_configs
          handle_list_configs(packet)
        when :select_config
          handle_select_config(packet)
        when :add_config
          handle_add_config(packet)
        when :update_config # rename config/file
          handle_update_config(packet)
        when :delete_config
          handle_delete_config(packet)
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
        if @host_is_a_connection
          title, message = packet.body.split(Packet::PROTOCOL_SEPERATOR, 2)
          $window.push_state(TAC::Dialog::TACNETDialog, title: title, message: message)
        end
      end

      def handle_upload_config(packet)
        begin
          config_name, json = packet.body.split(Packet::PROTOCOL_SEPERATOR, 2)
          data = JSON.parse(json, symbolize_names: true)

          if data.is_a?(Hash) && data.dig(:config, :spec_version) == TAC::CONFIG_SPEC_VERSION
            File.open("#{TAC::CONFIGS_PATH}/#{config_name}.json", "w") { |f| f.write json }

            if $window.backend.config&.name == config_name
              $window.backend.load_config(config_name)
            else
              $window.push_state(TAC::Dialog::AlertDialog, title: "Invalid Config", message: "Supported config spec: v#{TAC::CONFIG_SPEC_VERSION} got v#{data.dig(:config, :spec_version)}")
           end
          end

        rescue JSON::ParserError => e
          log.e(TAG, "JSON parsing error: #{e}")
        end
      end

      def handle_download_config(packet)
        config_name = packet.body
        log.i(TAG, config_name)
        pkt = nil

        if File.exist?("#{TAC::CONFIGS_PATH}/#{config_name}.json")
          pkt = PacketHandler.packet_upload_config(config_name, Config.new(config_name).to_json)
        else
          pkt = PacketHandler.packet_error("Remote config not found", "The requested config #{config_name} does not exist over here.")
        end

        if @host_is_a_connection
          $window.backend.tacnet.puts(pkt)
        else
          $server.active_client.puts(pkt)
        end
      end

      def handle_list_configs(packet)
        if @host_is_a_connection # Download new or updated configs
          list = packet.body.split(Packet::PROTOCOL_SEPERATOR).map { |part| part.split(",") }

          remote_configs = list.map { |l| l.first }
          local_configs = Dir.glob("#{TAC::CONFIGS_PATH}/*.json").map { |f| File.basename(f, ".json") }
          _diff = local_configs - remote_configs

          list.each do |name, revision|
            revision = Integer(revision)
            path = "#{TAC::CONFIGS_PATH}/#{name}.json"

            if File.exist?(path)
              config = Config.new(name)

              if config.configuration.revision < revision
                $window.backend.tacnet.puts( PacketHandler.packet_download_config(name) )
              elsif config.configuration.revision > revision
                $window.backend.tacnet.puts( PacketHandler.packet_upload_config(name, JSON.dump( config )) )
              end

            else
              $window.backend.tacnet.puts( PacketHandler.packet_download_config(name) )
            end
          end

          _diff.each do |name|
            config = Config.new(name)

            $window.backend.tacnet.puts( PacketHandler.packet_upload_config(name, JSON.dump( config )) )
          end
        else
          if $server.active_client && $server.active_client.connected?
            $server.active_client.puts(PacketHandler.packet_list_configs)
          end
        end
      end

      def handle_select_config(packet)
        config_name = packet.body

        $window.backend.settings.config = config_name
        $window.backend.save_settings
        $window.backend.load_config(config_name)
      end

      def handle_add_config(packet)
        config_name = packet.body

        if $window.backend.configs_list.include?(config_name)
          unless @host_is_a_connection
            if $server.active_client&.connected?
              $server.active_client.puts(PacketHandler.packet_error("Config already exists!", "A config with the name #{config_name} already exists over here."))
            end
          end
        else
          $window.backend.write_new_config(config_name)
        end
      end

      def handle_update_config(packet)
        old_config_name, new_config_name  = packet.body.split(PROTOCOL_SEPERATOR, 2)

        if $window.backend.configs_list.include?(config_name)
          unless @host_is_a_connection
            if $server.active_client&.connected?
              $server.active_client.puts(PacketHandler.packet_error("Config already exists!", "A config with the name #{config_name} already exists over here."))
            end
          end
        else
          $window.backend.move_config(old_config_name, new_config_name)
        end
      end

      def handle_delete_config(packet)
        config_name = packet.body

        $window.backend.delete_config(config_name)
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
        string = "#{config_name}#{Packet::PROTOCOL_SEPERATOR}#{json.gsub("\n", " ")}"

        Packet.create(Packet::PACKET_TYPES[:upload_config], string)
      end

      def self.packet_list_configs
        files = Dir.glob("#{TAC::CONFIGS_PATH}/*.json")
        list = files.map do |file|
          name = File.basename(file, ".json")
          config = Config.new(name)
          "#{name},#{config.configuration.revision}"
        end.join(Packet::PROTOCOL_SEPERATOR)

        Packet.create(
          Packet::PACKET_TYPES[:list_configs],
          list
        )
      end
    end
  end
end
