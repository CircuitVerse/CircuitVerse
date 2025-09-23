module Lookbook
  class ReloadChannel < ActionCable::Channel::Base
    def subscribed
      stream_from "reload"
    end
  end
end
