module Lookbook
  class InputStore
    CONFIG_FILE = "config/inputs.yml"

    DEFAULTS = {}

    attr_reader :store
    delegate :to_h, to: :store

    def initialize(config = nil)
      @store = {}

      config.to_h.each do |name, opts|
        opts[:system] = true
        add_input(name, opts[:partial], opts.except(:partial))
      end
    end

    def add_input(input, *args)
      store[normalize_name(input)] = build_config(input, *args)
    end

    def get_input(input)
      store[normalize_name(input)]
    end

    def self.init_from_config
      new(default_config)
    end

    def self.default_config
      ConfigLoader.call(CONFIG_FILE)
    end

    protected

    def normalize_name(name)
      name.to_s.tr("-", "_").to_sym
    end

    def build_config(name, *args)
      partial = nil
      opts = nil
      if args.many? && args.last.is_a?(Hash)
        partial = args.first
        opts = args.last
      elsif args.first.is_a?(String)
        partial = args.first
      end
      if partial.present?
        input = Store.new({
          name: name.to_sym,
          partial: partial,
          options: DEFAULTS.merge(opts.to_h)
        })
        if input.options.key?(:system)
          input.system = input.options[:system]
          input.options.delete(:system)
        end
        input
      else
        raise ConfigError.new("inputs must define a partial path", scope: "inputs.config")
      end
    end
  end
end
