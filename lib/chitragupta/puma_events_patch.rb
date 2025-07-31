module Chitragupta
  module PumaLoggerIntegration
    extend self

    def install!
      return unless should_patch_puma?
      
      patch_log_formatter
      patch_error_methods
    end

    private

    def should_patch_puma?
      defined?(Puma::LogWriter) && 
      (Chitragupta::Util.called_as_rails_server? || Chitragupta::Util.called_as_rack_server?)
    end

    def patch_log_formatter
      # Patch Puma's log_formatter if it's not already set
      return if defined?(::Rails) && ::Rails.application.config.respond_to?(:puma) && 
                ::Rails.application.config.puma.respond_to?(:log_formatter)
      
      # Add to Rails config if possible, otherwise patch directly
      if defined?(::Rails) && ::Rails.application
        ::Rails.application.configure do
          # This will be set in config/puma.rb by our integration
        end
      end
    end

    def patch_error_methods
      return unless defined?(Puma::LogWriter)

      Puma::LogWriter.class_eval do
        # Helper method to send any Puma log through Chitragupta
        def chitragupta_log(message, level: 'INFO')
          return unless defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger

          # Create Chitragupta-compatible log entry
          log_data = {
            log: {
              id: 'Puma',
              message: message.to_s.strip,
              level: level,
              kind: Chitragupta::Constants::KIND_PUMA_SERVER
            }
          }

          Rails.logger.info(log_data)
        rescue => e
          # Fallback: execute original behavior if provided
          yield if block_given?
        end

        # Override all error logging methods
        %w[parse_error connection_error ssl_error unknown_error debug_error error].each do |method_name|
          next unless method_defined?(method_name)
          
          alias_method :"original_#{method_name}", method_name.to_sym
          
          case method_name
          when 'parse_error'
            define_method(method_name) do |error, req|
              msg = build_parse_error_message(error, req)
              chitragupta_log(msg, level: 'ERROR') { send(:"original_#{method_name}", error, req) }
            end
            
          when 'connection_error'
            define_method(method_name) do |error, req, text="HTTP connection error"|
              msg = build_connection_error_message(error, req, text)
              chitragupta_log(msg, level: 'ERROR') { send(:"original_#{method_name}", error, req, text) }
            end
            
          when 'ssl_error'
            define_method(method_name) do |error, ssl_socket|
              msg = build_ssl_error_message(error, ssl_socket)
              chitragupta_log(msg, level: 'ERROR') { send(:"original_#{method_name}", error, ssl_socket) }
            end
            
          when 'unknown_error'
            define_method(method_name) do |error, req=nil, text="Unknown error"|
              msg = build_unknown_error_message(error, req, text)
              chitragupta_log(msg, level: 'ERROR') { send(:"original_#{method_name}", error, req, text) }
            end
            
          when 'debug_error'
            define_method(method_name) do |error, req=nil, text=""|
              return unless @debug  # respect debug mode
              msg = build_debug_error_message(error, req, text)
              chitragupta_log(msg, level: 'DEBUG') { send(:"original_#{method_name}", error, req, text) }
            end
            
          when 'error'
            define_method(method_name) do |str|
              msg = "FATAL: #{@formatter.call(str)}"
              chitragupta_log(msg, level: 'FATAL') { send(:"original_#{method_name}", str) }
              exit 1
            end
          end
        end

        private

        def build_parse_error_message(error, req)
          msg = "HTTP parse error, malformed request"
          msg += build_request_context(req) if req
          msg += ": #{error.inspect}" if error
          msg
        end

        def build_connection_error_message(error, req, text)
          msg = text.to_s
          msg += build_request_context(req) if req
          msg += ": #{error.inspect}" if error
          msg
        end

        def build_ssl_error_message(error, ssl_socket)
          peeraddr = ssl_socket.peeraddr.last rescue "<unknown>"
          peercert = ssl_socket.peercert
          subject = peercert&.subject
          msg = "SSL error, peer: #{peeraddr}, peer cert: #{subject}"
          msg += ": #{error.inspect}" if error
          msg
        end

        def build_unknown_error_message(error, req, text)
          msg = text.to_s
          msg += build_request_context(req) if req
          msg += ": #{error.inspect}" if error
          msg
        end

        def build_debug_error_message(error, req, text)
          msg = text.to_s.empty? ? "Debug error" : text.to_s
          msg += build_request_context(req) if req
          msg += ": #{error.inspect}" if error
          msg
        end

        def build_request_context(req)
          return "" unless req&.env&.dig('REQUEST_METHOD')
          
          path = req.env['REQUEST_PATH'] || req.env['PATH_INFO'] || ""
          query = req.env['QUERY_STRING'] || ""
          addr = req.env['HTTP_X_FORWARDED_FOR'] || req.env['REMOTE_ADDR'] || "-"
          
          " (\"#{req.env['REQUEST_METHOD']} #{path}#{query.empty? ? '' : '?' + query}\" - (#{addr}))"
        end
      end
    end
  end
end
