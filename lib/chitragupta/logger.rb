require "syslog/logger"

module Chitragupta
  class Loggerq < Syslog::Logger
    def initialize(*args, should_trim_long_string: false)
      super(*args)
      @formatter = Chitragupta::JsonLogFormatter.new(should_trim_long_string)
    end
  end
end
