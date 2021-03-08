module Chitragupta
  class Logger
    def initialize(device)
      logger = Logger.new(device)
      logger.formatter = Chitragupta::JsonLogFormatter.new
      return logger
    end
  end
end
