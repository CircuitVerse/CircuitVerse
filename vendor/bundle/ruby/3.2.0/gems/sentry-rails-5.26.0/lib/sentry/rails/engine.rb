# frozen_string_literal: true

module Sentry
  class Engine < ::Rails::Engine
    isolate_namespace Sentry
  end
end
