module Chitragupta
  module PumaConfigHelper
    extend self

    # Generate the log_formatter block for config/puma.rb
    def log_formatter_block
      proc do |msg|
        begin
          if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
            # Send through Rails.logger which has Chitragupta formatting
            Rails.logger.info({ 
              log: { 
                id: 'Puma', 
                message: msg.strip,
                kind: Chitragupta::Constants::KIND_PUMA_SERVER
              } 
            })
          else
            # Fallback to STDOUT if Rails isn't ready yet
            STDOUT.puts msg.strip
          end
        rescue
          STDOUT.puts msg.strip
        end
        # Return empty string to suppress duplicate output
        ""
      end
    end

    # Helper method that can be called from config/puma.rb
    def setup_puma_logging
      log_formatter(&log_formatter_block)
    end
  end
end
