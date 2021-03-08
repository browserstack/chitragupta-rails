require "securerandom"
require "chitragupta/version"
require "chitragupta/constants"
require "chitragupta/categories"
require "chitragupta/format_versions"
require "chitragupta/util"
require "chitragupta/json_log_formatter"
require "chitragupta/logger"

module Chitragupta
  extend self
  attr_accessor :payload

  # The gem can be used by adding the following in any of the rails initializations: application.rb / environment.rb
  # Chitragupta::setup_application_logger(RailsApplicationModule, current_user_function)
  def setup_application_logger(app, current_user_caller=nil)

    if Chitragupta::Util.called_as_rails_server?
      require "lograge"
      require "chitragupta/active_support/tagged_logging/formatter"
      require "chitragupta/active_support/instrumentation"

      ActionController::Instrumentation.current_user_caller = current_user_caller

      ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |_name, _started, _finished, _unique_id, data|
        Chitragupta.payload = data
      end
    end

    if Chitragupta::Util.called_as_rake?
      require "chitragupta/rake/task"
    end

    if Chitragupta::Util.called_as_sidekiq?
      Sidekiq.logger.formatter = JsonLogFormatter.new
    end

    configure_app(app)
  end


  def get_unique_log_id
    return SecureRandom.uuid
  end

  private
  def configure_app(app)
    app::Application.configure do
      config.log_formatter = JsonLogFormatter.new if Chitragupta::Util.called_as_rails_server? || Chitragupta::Util.called_as_rake? || Chitragupta::Util.called_as_sidekiq?
      if Chitragupta::Util.called_as_rails_server?
        require "chitragupta/request_log_formatter"
        config.lograge.enabled = true
        config.lograge.formatter = RequestLogFormatter::FORMAT
      end

      # setting the log_tags to empty array to ensure that the message being generated does not contain the unwanted tags
      config.log_tags = []
    end
  end

end
