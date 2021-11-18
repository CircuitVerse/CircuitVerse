require 'commontator'

class Commontator::Engine < ::Rails::Engine
  isolate_namespace Commontator

  config.assets.precompile += [ 'commontator/*.png' ]
end
