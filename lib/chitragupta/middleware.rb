module Chitragupta
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Chitragupta.payload = {}
      @app.call(env)
    end
  end
end
