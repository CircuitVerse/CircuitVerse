module Lookbook
  class Service
    def self.call(*args, **kwargs, &block)
      new(*args, **kwargs).call(&block)
    end
  end
end
