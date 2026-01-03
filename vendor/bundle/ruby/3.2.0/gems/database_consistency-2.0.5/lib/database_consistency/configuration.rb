# frozen_string_literal: true

require 'yaml'

module DatabaseConsistency
  # The class to access configuration options
  class Configuration
    DEFAULT_PATH = '.database_consistency.yml'

    def initialize(file_paths = DEFAULT_PATH)
      existing_paths = existing_configurations(file_paths)

      if existing_paths.any?
        puts "Loaded configurations: #{existing_paths.join(', ')}"
      else
        puts 'No configurations were provided'
      end

      @configuration = extract_configurations(existing_paths)

      load_custom_checkers
    end

    def debug?
      log_level.to_s.match?(/DEBUG/i)
    end

    def colored?
      if ENV.key?('COLOR')
        ENV['COLOR'].match?(/1|true|yes/)
      else
        settings && settings['color']
      end
    end

    # @return [Boolean]
    def enabled?(*path)
      current = configuration

      value = global_enabling

      path.each do |key|
        current = find(key.to_s, current)
        return value unless current.is_a?(Hash)

        next if current['enabled'].nil?

        value = current['enabled']
      end

      value
    end

    def model_enabled?(model)
      database_enabled?(Helper.database_name(model)) && enabled?(model.name.to_s)
    end

    def database_enabled?(name)
      value = configuration.dig('DatabaseConsistencyDatabases', name, 'enabled')

      value.nil? ? true : value
    end

    private

    attr_reader :configuration

    def find(key, configuration)
      return configuration[key] if configuration.key?(key)

      configuration.find { |(k, _)| k.include?('*') && key.match?(generate_regexp(k)) }&.last
    end

    def generate_regexp(str)
      /\A#{str.gsub('*', '.*')}\z/
    end

    def existing_configurations(paths)
      Array(paths).select do |filepath|
        filepath && File.exist?(filepath)
      end
    end

    def extract_configurations(paths)
      Array(paths).each_with_object({}) do |filepath, result|
        data = load_yaml_config_file(filepath)
        content = data.is_a?(Hash) ? data : {}

        combine_configs!(result, content)
      end
    end

    def global_enabling
      value = configuration.dig('DatabaseConsistencyCheckers', 'All', 'enabled')

      value.nil? ? true : value
    end

    def load_yaml_config_file(filepath)
      if YAML.respond_to?(:safe_load_file)
        YAML.safe_load_file(filepath, aliases: true)
      else
        YAML.load_file(filepath)
      end
    end

    def combine_configs!(config, new_config)
      config.merge!(new_config) do |_key, val, new_val|
        if val.is_a?(Hash) && new_val.is_a?(Hash)
          combine_configs!(val, new_val)
        else
          new_val
        end
      end
    end

    def settings
      @settings ||= configuration['DatabaseConsistencySettings']
    end

    def log_level
      @log_level ||=
        if ENV.key?('LOG_LEVEL')
          ENV['LOG_LEVEL']
        else
          settings && settings['log_level']
        end
    end

    def load_custom_checkers
      return unless configuration.key?('require') && configuration['require'].is_a?(Array)

      configuration['require'].each do |path|
        require path
      end
    end
  end
end
