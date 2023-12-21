module Chitragupta
  module Constants

    KIND_RAILS_REQUEST = 'RAILS_REQUEST'
    LOG_LEVEL_INFO = 'info'
    CURRENT_USER_PREFIX = 'current_'

    THREAD_ID_PREFIX = "TID-"

    CATEGORY_SERVER = "server"
    CATEGORY_PROCESS = "process"
    CATEGORY_WORKER = "worker"

    FIELD_LENGTH_LIMITS = {
      :dynamic_data => 10000,
      :headers => 8000,
      :params => 8000
    }
  end
end
