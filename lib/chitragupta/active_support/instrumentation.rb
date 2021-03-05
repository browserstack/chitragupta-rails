module ActionController
  module Instrumentation
    mattr_accessor :current_user_caller

    def process_action(*args)
      raw_payload = {
        :controller => self.class.name,
        :action     => self.action_name,
        :user_id    => (send(current_user_caller).id rescue nil),
        :params     => request.filtered_parameters,
        :format     => request.format.try(:ref),
        :method     => request.method,
        :path       => (request.fullpath.split("?")[0] rescue "unknown"),
        :request_id => request.uuid,
        :ip         => request.ip
      }

      ActiveSupport::Notifications.instrument("start_processing.action_controller", raw_payload.dup)

      ActiveSupport::Notifications.instrument("process_action.action_controller", raw_payload) do |payload|
        begin
          result = super
          payload[:status] = response.status
          result
        ensure
          append_info_to_payload(payload)
        end
      end
    end

  end
end
