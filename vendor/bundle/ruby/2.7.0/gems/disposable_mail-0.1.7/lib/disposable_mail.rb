require 'disposable_mail/disposable'
require 'disposable_mail/rails/validator' if defined?(::ActiveModel)
require 'disposable_mail/rails/railtie' if defined?(Rails)
