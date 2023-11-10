require "syslog/logger"

module Chitragupta
  class Logger < Syslog::Logger
    def initialize(*args, should_trim_long_string: false)
      super(*args)
      @formatter = Chitragupta::JsonLogFormatter.new(should_trim_long_string)
    end
  end
end
