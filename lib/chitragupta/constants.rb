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
      :dynamic_data => 5,
      :headers => 6,
      :params => 7
    }
  end
end
