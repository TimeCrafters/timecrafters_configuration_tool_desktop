module TAC
  class PracticeGameClock
    class ClockNet
      class Logger
        def printer(message)
          # return
          puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S %Z")} #{message}"
        end

        def i(tag, message)
          printer("INFO #{tag}: #{message}")
        end

        def d(tag, message)
          printer("DEBUG #{tag}: #{message}")
        end

        def e(tag, message)
          printer("ERROR #{tag}: #{message}")
        end
      end
    end

    def log
      @logger ||= ClockNet::Logger.new
    end
  end
end
