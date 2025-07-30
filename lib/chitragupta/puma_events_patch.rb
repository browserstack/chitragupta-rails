module Chitragupta
  module PumaEventsPatch
    def self.install!
      return unless defined?(Rails) && defined?(Puma::Events)

      Rails.application.config.after_initialize do
        cg_logger = Rails.logger

        Puma::Events.singleton_class.attr_accessor :cg_logger
        Puma::Events.cg_logger = cg_logger

        Puma::Events.prepend(Module.new do
          def log(str)
            Puma::Events.cg_logger.info(str)
            super
          end

          def log_error(str)
            Puma::Events.cg_logger.error(str)
            super
          end
        end)
      end
    end
  end
end
