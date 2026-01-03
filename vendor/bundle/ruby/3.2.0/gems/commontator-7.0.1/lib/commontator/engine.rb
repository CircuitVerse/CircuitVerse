require 'commontator'
require 'sprockets/railtie'

class Commontator::Engine < ::Rails::Engine
  isolate_namespace Commontator

  # Files in installed gems don't change during development,
  # but still cause issues in Rails 7 if autoloaded in an initializer
  # To fix this, make sure they are autoloaded only once
  config.autoload_once_paths = config.autoload_paths + config.eager_load_paths

  config.assets.precompile += [ 'commontator/*.png' ]
end
