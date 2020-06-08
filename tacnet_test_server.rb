require "gosu"
require "socket"
require "securerandom"

require_relative "lib/tac"
require_relative "lib/logger"

require_relative "lib/tacnet"
require_relative "lib/tacnet/packet"
require_relative "lib/tacnet/packet_handler"
require_relative "lib/tacnet/client"
require_relative "lib/tacnet/server"

Thread.report_on_exception = true

server = TAC::TACNET::Server.new
server.start(run_on_main_thread: true)