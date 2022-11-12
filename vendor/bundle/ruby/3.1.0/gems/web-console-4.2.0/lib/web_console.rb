# frozen_string_literal: true

require "active_support/dependencies/autoload"
require "active_support/logger"

module WebConsole
  extend ActiveSupport::Autoload

  autoload :View
  autoload :Evaluator
  autoload :ExceptionMapper
  autoload :Session
  autoload :Injector
  autoload :Interceptor
  autoload :Request
  autoload :WhinyRequest
  autoload :Permissions
  autoload :Template
  autoload :Middleware
  autoload :Context
  autoload :SourceLocation

  autoload_at "web_console/errors" do
    autoload :Error
    autoload :DoubleRenderError
  end

  def self.logger
    Rails.logger || (@logger ||= ActiveSupport::Logger.new($stderr))
  end
end

require "web_console/railtie"
