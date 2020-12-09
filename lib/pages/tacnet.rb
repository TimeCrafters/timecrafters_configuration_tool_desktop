module TAC
  class Pages
    class TACNET < Page
      def setup
        header_bar("TimeCrafters Auxiliary Configuration Network")

        menu_bar.clear do
          label "Hostname"
          hostname = edit_line "192.168.49.1", width: 0.33, height: 1.0
          label "Port"
          port = edit_line "192.168.49.1", width: 0.33, height: 1.0
          button "Connect", height: 1.0 do
            status_bar.clear do
              label "Connecting to #{hostname.value}:#{port.value}"
            end
          end
        end

        status_bar.clear do
          image "#{TAC::ROOT_PATH}/media/icons/signal3.png", height: 1.0
          label "TACNET: Connected    Pkt Sent: 00314    Pkt Received: 00313", text_size: 26
        end
      end
    end
  end
end