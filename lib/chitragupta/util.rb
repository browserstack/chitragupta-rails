require "socket"
require "json"

module Chitragupta
  module Util
    extend self

    def sanitize_keys(log_level, timestamp, message)
      data = initialize_data(message)

      data[:log][:level] = log_level
      data[:meta][:timestamp] = timestamp

      return "#{data.to_json.to_s}\n"
    end

    def called_as_rails_server?
      # Rails::Server works in development mode whereas ::PhusionPassenger in production environment
      return (defined?(Rails::Server) || defined?(::PhusionPassenger)) && true || false
    end

    def called_as_rack_server?
      # Check if its called using rack up and Rack server is defined to log for rack
      return File.basename($PROGRAM_NAME) == "rackup" && defined?(Rack::Server)
    end

    def called_as_sidekiq?
      return Sidekiq.server? && true || false
    end

    def called_as_rake?
      return File.basename($PROGRAM_NAME) == 'rake'
    end

    def called_as_console?
      return defined?(Rails::Console) && true || false
    end

    private
    def populate_server_data(data, message)
      data[:data][:request] = {}
      data[:data][:response] = {}
      data[:data][:request][:method] = Chitragupta.payload[:method]
      data[:data][:request][:endpoint] = Chitragupta.payload[:path]
      data[:data][:request][:ip] = Chitragupta.payload[:ip]
      data[:data][:request][:id] = Chitragupta.payload[:request_id]
      data[:data][:request][:user_id] = Chitragupta.payload[:user_id]
      data[:data][:request][:params] = Chitragupta.payload[:params].to_json.to_s

      data[:data][:response][:status] = message[:status] rescue nil
      data[:data][:response][:duration] = message[:duration] rescue nil

      data[:meta][:format][:category] = Chitragupta::Categories::SERVER
      data[:meta][:format][:version] = Chitragupta::FormatVersions::SERVER
      data[:meta][:host] = Socket.gethostname

      data[:log][:id] ||= Chitragupta.payload[:log_id]
    end

    def populate_rails_server_data(data, message)
      populate_server_data(data, message)
      data[:data][:request][:controller] = Chitragupta.payload[:controller]
      data[:data][:request][:action] = Chitragupta.payload[:action]

      data[:data][:response][:view_rendering_duration] = message[:view] rescue nil
      data[:data][:response][:db_query_duration] = message[:db] rescue nil
      data[:data][:response][:db_query_count] = message[:query_count] rescue nil
    end

    def populate_ruby_server_data(data, message)
      populate_server_data(data, message)
    end

    def populate_task_data(data, message)
      data[:data][:name] = Rake.application.current_task
      data[:data][:execution_id] = Rake.application.execution_id

      data[:meta][:format][:category] = Chitragupta::Categories::PROCESS
      data[:meta][:format][:version] = Chitragupta::FormatVersions::PROCESS
      data[:meta][:host] = Socket.gethostname
    end

    def populate_worker_data(data, message)
      data[:meta][:format][:category] = Chitragupta::Categories::WORKER
      data[:meta][:format][:version] = Chitragupta::FormatVersions::WORKER
      data[:meta][:host] = Socket.gethostname

      data[:data][:thread_id] = Chitragupta::Constants::THREAD_ID_PREFIX + Thread.current.object_id.to_s(36)
      if Thread.current[:sidekiq_context].nil?
        return
      end
      worker_name, job_id = Thread.current[:sidekiq_context][0].split
      data[:data][:job_id] = job_id
      data[:data][:worker_name] = worker_name
    end

    def initialize_data(message)
      data = {}
      data[:data] = {}

      if message.is_a?(Hash)
        data[:log] = message[:log] || {}
        data[:meta] = message[:meta] || {}
      else
        data[:log] = {}
        data[:meta] = {}
        data[:log][:dynamic_data] = message.is_a?(String) ? message : message.inspect if message
      end

      data[:meta][:format] ||= {}
      begin
        if called_as_rails_server?
          populate_rails_server_data(data, message)
        elsif called_as_rack_server?
          populate_ruby_server_data(data, message)
        elsif called_as_rake?
          populate_task_data(data, message)
        elsif called_as_sidekiq?
          populate_worker_data(data, message)
        end
      rescue; end
      return data
    end

  end
end
