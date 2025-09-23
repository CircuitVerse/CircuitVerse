module Lookbook
  class ConfigError < Error
    def initialize(msg = nil, scope: "config", **kwargs)
      super
    end
  end
end
