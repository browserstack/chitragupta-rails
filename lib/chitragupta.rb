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

    # Should be required only when the rails application is configuring the gem to be used.
    require "chitragupta/active_support/tagged_logging/formatter"

    if Chitragupta::Util.called_as_rails_server?
      require "lograge"
      require "chitragupta/active_support/instrumentation"

      ActionController::Instrumentation.current_user_caller = current_user_caller

      ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |_name, _started, _finished, _unique_id, data|
        data[:params] = Chitragupta::Util::trim_long_string(data[:params].to_json.to_s, Chitragupta::Constants::FIELD_LENGTH_LIMITS[:params])
        data[:headers] = Chitragupta::Util::trim_long_string(data[:headers].to_h.to_json.to_s, Chitragupta::Constants::FIELD_LENGTH_LIMITS[:headers])
        Chitragupta.payload = data
      end

      ActiveSupport::Notifications.subscribe "halted_callback.action_controller" do |_name, _started, _finished, _unique_id, data|
        Rails.logger.info({ log: { kind: 'FILTER_CHAIN_HALTED', dynamic_data: "#{data[:filter].inspect} rendered or redirected" }})
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
