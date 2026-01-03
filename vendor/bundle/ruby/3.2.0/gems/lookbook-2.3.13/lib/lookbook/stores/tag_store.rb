module Lookbook
  class TagStore
    CONFIG_FILE = "config/tags.yml"

    attr_reader :store
    delegate :to_h, to: :store

    def initialize(config = nil)
      @store = {}
      config.to_h.each { |k, opts| add_tag(k, opts, true) }
    end

    def add_tag(name, opts = nil, is_system = false)
      name = name.to_sym
      if store.key?(name)
        raise ConfigError.new("tag with name '#{name}' already exists", scope: "tags.config")
      else
        store[name] = build_config(name, opts, is_system)
      end
    end

    def get_tag(name)
      store[name.to_sym]
    end

    def self.init_from_config
      new(default_config)
    end

    def self.default_config
      ConfigLoader.call(CONFIG_FILE)
    end

    protected

    def build_config(name, opts = nil, is_system = false)
      Store.new({
        name: name.to_sym,
        label: name.to_s.titleize,
        options: opts.to_h,
        system: is_system
      })
    end
  end
end
