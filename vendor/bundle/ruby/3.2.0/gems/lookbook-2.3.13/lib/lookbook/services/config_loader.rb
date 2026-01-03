module Lookbook
  class ConfigLoader < Service
    attr_reader :file, :env

    def initialize(path, env: Rails.env)
      @file = Engine.root.join(path)
      @env = env.to_sym
    end

    def call
      if file.exist?
        config = YAML.load_file(file).deep_symbolize_keys
        env_config = config[:shared].to_h.deep_merge(config[env].to_h)
        Store.new(env_config)
      else
        raise ConfigError.new("Could not load configuration. No such file - #{file}")
      end
    end
  end
end
