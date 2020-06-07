require_relative "../cyberarm_engine/lib/cyberarm_engine"
require "socket"
require "json"

require "faker"

require_relative "lib/palette"
require_relative "lib/window"
require_relative "lib/version"
require_relative "lib/storage"
require_relative "lib/states/editor"

TAC::Window.new(width: (Gosu.screen_width * 0.8).round, height: (Gosu.screen_height * 0.8).round, resizable: true).show