module TAC
  class PracticeGameClock
    class ClockNet
  class PacketHandler
    TAG = "ClockNet|PacketHandler"
    def initialize(host_is_a_connection: false, proxy_object:)
      @host_is_a_connection = host_is_a_connection
      @proxy_object = proxy_object
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

      when :start_clock
        handle_start_clock(packet)
      when :abort_clock
        handle_abort_clock(packet)
      when :get_clock_title
        handle_get_clock_title(packet)
      when :set_clock_title
        handle_set_clock_title(packet)
      when :clock_title
        handle_clock_title(packet)
      when :jukebox_previous_track
        handle_jukebox_previous_track(packet)
      when :jukebox_next_track
        handle_jukebox_next_track(packet)
      when :jukebox_play
        handle_jukebox_play(packet)
      when :jukebox_pause
        handle_jukebox_pause(packet)
      when :jukebox_stop
        handle_jukebox_stop(packet)
      when :jukebox_set_volume
        handle_jukebox_set_volume(packet)
      when :jukebox_volume
        handle_jukebox_volume(packet)
      when :jukebox_set_sound_effects
        handle_jukebox_set_sound_effects(packet)
      when :jukebox_current_track
        handle_jukebox_current_track(packet)
      when :clock_time
        handle_clock_time(packet)
      when :randomizer_visible
        handle_randomizer_visible(packet)
      when :shutdown
        handle_shutdown(packet)
      else
        log.d(TAG, "No hand off available for packet type: #{packet.type}")
      end
    end

    def handle_handshake(packet)
      if @host_is_a_connection
      end
    end

    # TODO: Reset socket timeout
    def handle_heartbeat(packet)
    end

    # TODO: Handle errors
    def handle_error(packet)
      title, message = packet.body.split(Packet::PROTOCOL_SEPERATOR, 2)
      log.e(TAG, "Remote error: #{title}: #{message}")
    end

    def handle_start_clock(packet)
      unless @host_is_a_connection
        @proxy_object.start_clock(packet.body.to_sym)
      end
    end

    def handle_abort_clock(packet)
      unless @host_is_a_connection
        @proxy_object.abort_clock
      end
    end

    def handle_set_clock_title(packet)
      unless @host_is_a_connection
        title = packet.body
        @proxy_object.set_clock_title(title)
      end
    end

    def handle_get_clock_title(packet)
      unless @host_is_a_connection
        RemoteControl.server.active_client.puts(Packet.clock_title(@proxy_object.clock.title))
      end
    end

    def handle_jukebox_previous_track(packet)
      unless @host_is_a_connection
        @proxy_object.jukebox_previous_track

        RemoteControl.server.active_client.puts(PacketHandler.packet_jukebox_current_track(@proxy_object.jukebox_current_track))
      end
    end

    def handle_jukebox_next_track(packet)
      unless @host_is_a_connection
        @proxy_object.jukebox_next_track

        RemoteControl.server.active_client.puts(PacketHandler.packet_jukebox_current_track(@proxy_object.jukebox_current_track))
      end
    end

    def handle_jukebox_play(packet)
      unless @host_is_a_connection
        @proxy_object.jukebox_play

        RemoteControl.server.active_client.puts(PacketHandler.packet_jukebox_current_track(@proxy_object.jukebox_current_track))
      end
    end

    def handle_jukebox_pause(packet)
      unless @host_is_a_connection
        @proxy_object.jukebox_pause

        RemoteControl.server.active_client.puts(PacketHandler.packet_jukebox_current_track(@proxy_object.jukebox_current_track))
      end
    end

    def handle_jukebox_stop(packet)
      unless @host_is_a_connection
        @proxy_object.jukebox_stop

        RemoteControl.server.active_client.puts(PacketHandler.packet_jukebox_current_track(@proxy_object.jukebox_current_track))
      end
    end

    def handle_jukebox_set_volume(packet)
      unless @host_is_a_connection
        float = packet.body.to_f
        float = float.clamp(0.0, 1.0)

        @proxy_object.jukebox_set_volume(float)

        float = @proxy_object.jukebox_volume
        RemoteControl.server.active_client.puts(PacketHandler.packet_jukebox_volume(float))
      end
    end

    def handle_jukebox_get_volume(packet)
      unless @host_is_a_connection
        float = @proxy_object.jukebox_volume

        RemoteControl.server.active_client.puts(PacketHandler.packet_jukebox_volume(float))
      end
    end

    def handle_jukebox_volume(packet)
      if @host_is_a_connection
        float = packet.body.to_f

        @proxy_object.volume_changed(float)
      end
    end

    def handle_jukebox_set_sound_effects(packet)
      unless @host_is_a_connection
        boolean = packet.body == "true"

        @proxy_object.jukebox_set_sound_effects(boolean)
      end
    end

    def handle_jukebox_current_track(packet)
      if @host_is_a_connection
        @proxy_object.track_changed(packet.body)
      end
    end

    def handle_clock_time(packet)
      if @host_is_a_connection
        @proxy_object.clock_changed(packet.body)
      end
    end

    def handle_randomizer_visible(packet)
      boolean = packet.body == "true"

      @proxy_object.randomizer_changed(boolean)

      unless @host_is_a_connection
        # Send confirmation to client
        RemoteControl.server.active_client.puts(PacketHandler.packet_randomizer_visible(boolean))
      end
    end

    def handle_shutdown(packet)
      unless @host_is_a_connection
        # RemoteControl.server.close
        # $window.close
        Gosu::Song.current_song&.stop
        exit
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

    def self.packet_start_clock(mode)
      Packet.create(Packet::PACKET_TYPES[:start_clock], mode.to_s)
    end

    def self.packet_abort_clock
      Packet.create(Packet::PACKET_TYPES[:abort_clock], "")
    end

    def self.packet_set_clock_title(string)
      Packet.create(Packet::PACKET_TYPES[:set_clock_title], string.to_s)
    end

    def self.packet_get_clock_title
      Packet.create(Packet::PACKET_TYPES[:get_clock_title], "")
    end

    def self.packet_clock_title(string)
      Packet.create(Packet::PACKET_TYPES[:clock_title], string.to_s)
    end

    def self.packet_jukebox_previous_track
      Packet.create(Packet::PACKET_TYPES[:jukebox_previous_track], "")
    end

    def self.packet_jukebox_next_track
      Packet.create(Packet::PACKET_TYPES[:jukebox_next_track], "")
    end

    def self.packet_jukebox_play
      Packet.create(Packet::PACKET_TYPES[:jukebox_play], "")
    end

    def self.packet_jukebox_pause
      Packet.create(Packet::PACKET_TYPES[:jukebox_pause], "")
    end

    def self.packet_jukebox_stop
      Packet.create(Packet::PACKET_TYPES[:jukebox_stop], "")
    end

    def self.packet_jukebox_set_volume(float)
      Packet.create(Packet::PACKET_TYPES[:jukebox_set_volume], float.to_s)
    end

    def self.packet_jukebox_get_volume
      Packet.create(Packet::PACKET_TYPES[:jukebox_get_volume], "")
    end

    def self.packet_jukebox_volume(float)
      Packet.create(Packet::PACKET_TYPES[:jukebox_volume], float.to_s)
    end

    def self.packet_jukebox_set_sound_effects(boolean)
      Packet.create(Packet::PACKET_TYPES[:jukebox_set_sound_effects], boolean.to_s)
    end

    def self.packet_jukebox_current_track(name)
      Packet.create(Packet::PACKET_TYPES[:jukebox_current_track], name)
    end

    def self.packet_clock_time(string)
      Packet.create(Packet::PACKET_TYPES[:clock_time], string)
    end

    def self.packet_randomizer_visible(boolean)
      Packet.create(Packet::PACKET_TYPES[:randomizer_visible], boolean.to_s)
    end

    def self.packet_shutdown
      Packet.create(Packet::PACKET_TYPES[:shutdown], "")
    end
  end
    end
  end
end
