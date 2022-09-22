# frozen_string_literal: true

require "rack/body_proxy"

module ActionDispatch
  class Executor
    def initialize(app, executor)
      @app, @executor = app, executor
    end

    def call(env)
      state = @executor.run!(reset: true)
      begin
        response = @app.call(env)
        returned = response << ::Rack::BodyProxy.new(response.pop) { state.complete! }
      rescue => error
        @executor.error_reporter.report(error, handled: false)
        raise
      ensure
        state.complete! unless returned
      end
    end
  end
end
