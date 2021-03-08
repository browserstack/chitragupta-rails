module Chitragupta
  class Logger < ::Logger
    def initialize(*args)
      super(*args)
      @formatter = Chitragupta::JsonLogFormatter.new
    end
  end
end
