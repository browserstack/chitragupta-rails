module Chitragupta
  module Constants

    KIND_RAILS_REQUEST = 'RAILS_REQUEST'
    LOG_LEVEL_INFO = 'info'
    CURRENT_USER_PREFIX = 'current_'

    THREAD_ID_PREFIX = "TID-"

    CATEGORY_SERVER = "server"
    CATEGORY_PROCESS = "process"
    CATEGORY_WORKER = "worker"

    DEFAULT_FILTER_KEYS = %w[password secret token api_key authorization access_token].freeze
    FILTERED_VALUE = '[FILTERED]'

    FIELD_LENGTH_LIMITS = {
      :dynamic_data => 5000,
      :headers => 1000,
      :params => 10000
    }
  end
end
