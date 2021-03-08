module Chitragupta
  class Logger < ::Logger
    def initialize(*)
      logger = super(*)
      logger.formatter = Chitragupta::JsonLogFormatter.new
      return logger
    end
  end
end
