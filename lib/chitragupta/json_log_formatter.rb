module Chitragupta
  class JsonLogFormatter < Logger::Formatter
    def initialize(should_trim_long_string=false)
      @should_trim_long_string = should_trim_long_string
    end

    def call(log_level, timestamp, _progname, message)
      puts("inside caa")
      # return "inside_call - #{@should_trim_long_string}"
      final_str = Chitragupta::Util::sanitize_keys(log_level, timestamp, message, @should_trim_long_string)
      puts("final_str - #{final_str}")
      return final_str
    end
  end
end
