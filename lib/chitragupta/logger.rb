require "syslog/logger"

module Chitragupta
  class Logger < Syslog::Logger
    def initialize(*args)
      super(*args)
      @formatter = Chitragupta::JsonLogFormatter.new
    end
  end
end
