module Lookbook
  class NullWebsocket < NullObject
    def mountable?
      false
    end

    alias_method :mounted?, :mountable?
  end
end
