module TAC
  class Pages
    class TACNET < Page
      def setup
        header_bar("TimeCrafters Auxiliary Configuration Network")

        menu_bar.clear do
          @connect_menu = flow(width: 1.0, height: 1.0) do
            label "Hostname", text_size: 28
            hostname = edit_line window.backend.settings.hostname, width: 0.33, height: 1.0, text_size: 28
            label "Port", text_size: 28
            port = edit_line window.backend.settings.port, width: 0.33, height: 1.0, text_size: 28
            button "Connect", height: 1.0, text_size: 28 do
              if hostname.value != window.backend.settings.hostname || port.value.to_i != window.backend.settings.port
                window.backend.settings_changed!
              end

              window.backend.settings.hostname = hostname.value
              window.backend.settings.port = port.value.to_i

              window.backend.tacnet.connect(hostname.value, port.value.to_i)
            end
          end

          @disconnect_menu = flow(width: 1.0, height: 1.0) do
            button "Disconnect", height: 1.0, text_size: 28 do
              window.backend.tacnet.close
            end
          end
        end

        status_bar.clear do
          @tacnet_icon = image "#{TAC::MEDIA_PATH}/icons/signal3.png", height: 26
          @status_label = label "TACNET: Not Connected", text_size: 26
        end

        body.clear do
          @full_status_label = label ""
        end
      end

      def update
        case window.backend.tacnet.status
        when :connected
          sent = "#{window.backend.tacnet.client.packets_sent}".rjust(4, '0')
          received = "#{window.backend.tacnet.client.packets_received}".rjust(4, '0')
          @status_label.value = "TACNET: Connected    Pkt Sent: #{sent}    Pkt Received: #{received}"
          @full_status_label.value = window.backend.tacnet.full_status
          @tacnet_icon.style.color = TAC::Palette::TACNET_CONNECTED
          @connect_menu.hide
          @disconnect_menu.show

        when :connecting
          @status_label.value = "TACNET: Connecting..."
          @tacnet_icon.style.color = TAC::Palette::TACNET_CONNECTING
          @connect_menu.hide
          @disconnect_menu.show

        when :connection_error
          @status_label.value = "TACNET: Connection Error"
          @full_status_label.value = window.backend.tacnet.full_status
          @tacnet_icon.style.color = TAC::Palette::TACNET_CONNECTION_ERROR
          @connect_menu.show
          @disconnect_menu.hide

        when :not_connected
          @status_label.value = "TACNET: Not Connected"
          @full_status_label.value = ""
          @tacnet_icon.style.color = 0xff_ffffff
          @connect_menu.show
          @disconnect_menu.hide
        end
      end
    end
  end
end