module Lookbook
  class RoutingError < Error
    def initialize(msg = nil, scope: "request", **kwargs)
      super(msg, scope: scope, status: :not_found, **kwargs)
    end
  end
end
