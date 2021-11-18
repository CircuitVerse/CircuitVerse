# frozen_string_literal: true

module ServiceWorker
  class Router
    PATH_INFO = "PATH_INFO"

    def self.default
      new.draw_default
    end

    attr_reader :routes

    def initialize
      @routes = []

      draw(&Proc.new) if block_given?
    end

    def draw(&block)
      return self unless block_given?

      if block.arity == 1
        yield(self)
      else
        instance_eval(&block)
      end

      self
    end

    def draw_default
      draw { get "/serviceworker.js" }
    end

    def match(path, *args)
      if path.is_a?(Hash)
        opts = path.to_a
        path, asset = opts.shift
        args = [asset, opts.to_h]
      end

      Route.new(path, *args).tap do |route|
        @routes << route
      end
    end
    alias get match

    def any?
      @routes.any?
    end

    def match_route(env)
      path = env[PATH_INFO]
      @routes.each do |route|
        match = route.match(path) and return match
      end
      nil
    end
  end
end
