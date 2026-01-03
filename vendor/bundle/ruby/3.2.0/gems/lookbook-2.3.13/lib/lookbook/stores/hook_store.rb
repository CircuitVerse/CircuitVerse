module Lookbook
  class HookStore
    attr_reader :store
    delegate :to_h, to: :store

    def initialize(config = nil)
      @store = {}
    end

    def add_hook(event_name, callback)
      for_event(event_name) << callback
    end

    def for_event(event_name)
      store[event_name.to_sym] ||= []
    end
  end
end
