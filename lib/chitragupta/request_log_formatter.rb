require 'chitragupta/constants'

module Chitragupta
  module RequestLogFormatter
    FORMAT = ->(message) {
        message[:log] = {}
        message[:log][:kind] = Chitragupta::Constants::KIND_RAILS_REQUEST
        return message
      }
  end
end
