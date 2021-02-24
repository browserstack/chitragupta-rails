module Chitragupta
  class JsonLogFormatter < Logger::Formatter

    def call(log_level, timestamp, _progname, message)
      return Chitragupta::Util::sanitize_keys(log_level, timestamp, message)
    end
  end
end
