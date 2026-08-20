require "rack/body_proxy"

module Chitragupta
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Chitragupta.payload = {}
      status, headers, body = @app.call(env)
      [status, headers, Rack::BodyProxy.new(body) { Chitragupta.payload = {} }]
    rescue Exception
      Chitragupta.payload = {}
      raise
    end
  end
end
