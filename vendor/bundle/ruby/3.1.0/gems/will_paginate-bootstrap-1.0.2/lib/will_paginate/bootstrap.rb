require 'will_paginate'

if defined?(ActionView)
  require "bootstrap_pagination/action_view"
end

if defined?(Sinatra)
  require "bootstrap_pagination/sinatra"
end
