module Remotipart
  module Rails
    if ::Rails.version.to_s < "3.1"
      require 'remotipart/rails/railtie'
    else
      require 'remotipart/rails/engine'
    end
    require 'remotipart/rails/version'
  end
end
