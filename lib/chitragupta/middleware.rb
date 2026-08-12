module Chitragupta
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Chitragupta.payload = {}
      @app.call(env)
    ensure
      Chitragupta.payload = {}
    end
  end
end
