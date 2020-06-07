require_relative "../cyberarm_engine/lib/cyberarm_engine"
require "socket"
require "json"

require "faker"

require_relative "lib/tac"
require_relative "lib/palette"
require_relative "lib/window"
require_relative "lib/version"
require_relative "lib/storage"
require_relative "lib/backend"
require_relative "lib/states/editor"
require_relative "lib/theme"
require_relative "lib/dialog"
require_relative "lib/dialogs/name_prompt_dialog"
require_relative "lib/tacnet"
require_relative "lib/tacnet/packet"
require_relative "lib/tacnet/packet_handler"
require_relative "lib/tacnet/client"
require_relative "lib/tacnet/connection"
require_relative "lib/tacnet/server"

Thread.abort_on_exception = true

TAC::Window.new(width: (Gosu.screen_width * 0.8).round, height: (Gosu.screen_height * 0.8).round, resizable: true).show