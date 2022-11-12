require "will_paginate/view_helpers/sinatra"
require "bootstrap_pagination/bootstrap_renderer"

module BootstrapPagination
  # A custom renderer class for WillPaginate that produces markup suitable for use with Twitter Bootstrap.
  class Sinatra < WillPaginate::Sinatra::LinkRenderer
    include BootstrapRenderer
  end
end
