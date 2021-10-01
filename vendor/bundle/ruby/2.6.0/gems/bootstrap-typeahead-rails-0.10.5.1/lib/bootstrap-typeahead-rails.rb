require "rails"
require "bootstrap-typeahead-rails/version"

module BootstrapTypeaheadRails
  module Rails
    if ::Rails.version.to_s < "3.1"
      require "bootstrap-typeahead-rails/railtie"
    else
      require "bootstrap-typeahead-rails/engine"
    end
  end
end
