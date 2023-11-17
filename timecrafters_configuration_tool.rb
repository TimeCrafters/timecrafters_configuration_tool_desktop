begin
  raise LoadError if defined?(Ocra)
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end
require "socket"
require "securerandom"
require "json"
require "fileutils"

require_relative "lib/tac"
require_relative "lib/palette"
require_relative "lib/window"
require_relative "lib/version"
require_relative "lib/backend"
require_relative "lib/config"
require_relative "lib/settings"
require_relative "lib/states/boot"
require_relative "lib/states/editor"
require_relative "lib/page"
require_relative "lib/pages/home"
require_relative "lib/pages/editor"
require_relative "lib/pages/tacnet"
require_relative "lib/pages/simulator"
require_relative "lib/pages/configurations"
require_relative "lib/pages/presets"
require_relative "lib/pages/search"
require_relative "lib/pages/field_planner"
require_relative "lib/pages/drive_team_rotation_generator"
require_relative "lib/pages/game_clock"
require_relative "lib/simulator/robot"
require_relative "lib/simulator/field"
require_relative "lib/simulator/simulation"
require_relative "lib/theme"
require_relative "lib/logger"
require_relative "lib/dialog"
require_relative "lib/dialogs/alert_dialog"
require_relative "lib/dialogs/confirm_dialog"
require_relative "lib/dialogs/name_prompt_dialog"
require_relative "lib/dialogs/action_dialog"
require_relative "lib/dialogs/variable_dialog"
require_relative "lib/dialogs/tacnet_dialog"
require_relative "lib/dialogs/tacnet_status_dialog"
require_relative "lib/dialogs/pick_preset_dialog"
require_relative "lib/tacnet"
require_relative "lib/tacnet/packet"
require_relative "lib/tacnet/packet_handler"
require_relative "lib/tacnet/client"
require_relative "lib/tacnet/connection"
require_relative "lib/tacnet/server"

require_relative "lib/game_clock/view"
require_relative "lib/game_clock/clock"
require_relative "lib/game_clock/event_handlers"
require_relative "lib/game_clock/clock_controller"
require_relative "lib/game_clock/jukebox"
require_relative "lib/game_clock/theme"
require_relative "lib/game_clock/clock_proxy"
require_relative "lib/game_clock/logger"
require_relative "lib/game_clock/particle_emitter"
require_relative "lib/game_clock/randomizer"
require_relative "lib/game_clock/remote_control"
require_relative "lib/game_clock/remote_proxy"
require_relative "lib/game_clock/net/client"
require_relative "lib/game_clock/net/server"
require_relative "lib/game_clock/net/connection"
require_relative "lib/game_clock/net/packet_handler"
require_relative "lib/game_clock/net/packet"

# Thread.abort_on_exception = true

USE_REDESIGN = ARGV.include?("--redesign")
BORDERLESS = ARGV.include?("--borderless")

if not defined?(Ocra)
  TAC::Window.new(width: (Gosu.screen_width * 0.8).round, height: (Gosu.screen_height * 0.8).round, resizable: true, borderless: BORDERLESS).show
end

Process.wait($clock_pid) if $clock_pid
