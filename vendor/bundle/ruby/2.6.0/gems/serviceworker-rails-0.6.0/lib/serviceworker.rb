# frozen_string_literal: true

module ServiceWorker
  Error = Class.new(StandardError)
  RouteError = Class.new(Error)
end

require "serviceworker/route"
require "serviceworker/router"
require "serviceworker/middleware"
