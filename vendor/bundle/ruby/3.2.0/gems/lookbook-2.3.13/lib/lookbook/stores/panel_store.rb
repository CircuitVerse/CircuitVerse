module Lookbook
  class PanelStore
    CONFIG_FILE = "config/panels.yml"

    DEFAULTS = {
      label: lambda { |data| data.name.to_s.titleize },
      hotkey: nil,
      disabled: false,
      show: true,
      copy: nil,
      locals: {}
    }

    attr_reader :store
    delegate :to_h, to: :store

    def initialize(config = nil)
      @store = {}
      load_config(config)
    end

    def add_panel(name, *args)
      if get_panel(name)
        raise ConfigError.new("panel with name '#{name}' already exists", scope: "panels.config")
      else
        store[Utils.symbolize_name(name)] = build_config(name, *args)
      end
    end

    def update_panel(name, opts = {})
      panel = get_panel(name)
      if panel.present?
        panel.merge!(opts.except(:name))
      else
        not_found!(name)
      end
    end

    def remove_panel(name)
      store.delete(Utils.symbolize_name(name)) { |name| not_found!(name) }
    end

    def load_config(config)
      config.to_h.each do |name, opts|
        opts[:system] = true
        add_panel(name, opts)
      end
    end

    def get_panel(name)
      panels.find { |panel| panel.name == Utils.symbolize_name(name) }
    end

    def get_panels(*names)
      ListResolver.call(names.flatten, panels.map(&:name)) { |name| get_panel(name) }
    end

    def panels
      store.map { |name, panel| panel }
    end

    def names
      panels.map(&:name)
    end

    alias_method :all, :panels

    def self.resolve_config(opts, data)
      if opts[:name].present?
        data = data.is_a?(Store) ? data : Store.new(data)
        data.name = Utils.symbolize_name(opts[:name])
        resolved = opts.transform_values do |value|
          value.respond_to?(:call) ? value.call(data) : value
        end
        Store.new(resolved)
      else
        raise ConfigError.new(":name key is required when resolving config", scope: "panels.config")
      end
    end

    def self.init_from_config
      new(default_config)
    end

    def self.default_config
      config = ConfigLoader.call(CONFIG_FILE)
      config.to_h.transform_values! do |opts|
        opts.transform_values! do |value|
          if value.is_a?(String) && value.start_with?("->")
            proc {
              eval(value) # standard:disable Security/Eval
            }.call
          else
            value
          end
        end
      end
    end

    protected

    def build_config(name, *args)
      opts = if args.many? && args.first.is_a?(String) && args.last.is_a?(Hash)
        args.last.merge({partial: args.first})
      elsif args.any?
        args.first.is_a?(String) ? {partial: args.first} : args.first
      else
        {}
      end
      if opts[:partial].present?
        opts[:name] = Utils.symbolize_name(name)
        Store.new(DEFAULTS.merge(opts))
      else
        raise ConfigError.new("panels must define a partial path", scope: "panels.config")
      end
    end

    def not_found!(name)
      raise ConfigError.new("could not find panel named '#{name}'", scope: "panels.config")
    end
  end
end
