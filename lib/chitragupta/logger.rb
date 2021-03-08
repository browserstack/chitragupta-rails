module Chitragupta
  class Logger < ::Logger
    def initialize(*args, **kwargs)
      super
      @formatter = Chitragupta::JsonLogFormatter.new
    end
  end
end
