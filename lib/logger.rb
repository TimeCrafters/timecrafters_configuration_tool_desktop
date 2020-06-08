module TAC
  class Logger
    def printer(message)
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
  @logger ||= TAC::Logger.new
end