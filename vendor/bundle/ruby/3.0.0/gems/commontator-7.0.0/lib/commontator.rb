require 'will_paginate'
require 'commontator/version'

module Commontator
  # These requires need the Commontator module to function properly
  require 'commontator/engine'
  require 'commontator/config'
  require 'commontator/controllers'
  require 'commontator/acts_as_commontator'
  require 'commontator/acts_as_commontable'

  VERSION = COMMONTATOR_VERSION

  include Commontator::Config
end
