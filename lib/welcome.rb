module Rack
  class Welcome
    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env).path

      if req == '/welcome'
        [200, { 'Content-Type' => 'text/plain' }, ['Welcome!']]
      else
        @app.call(env)
      end
    end
  end
end