# frozen_string_literal: true

module DatabaseConsistency
  # The module contains helper methods
  module Helper
    module_function

    def adapter
      if ActiveRecord::Base.respond_to?(:connection_db_config)
        ActiveRecord::Base.connection_db_config.configuration_hash[:adapter]
      else
        ActiveRecord::Base.connection_config[:adapter]
      end
    end

    def database_name(model)
      model.connection_db_config.name.to_s if model.respond_to?(:connection_db_config)
    end

    def postgresql?
      adapter == 'postgresql'
    end

    def connection_config(klass)
      if klass.respond_to?(:connection_db_config)
        klass.connection_db_config.configuration_hash
      else
        klass.connection_config
      end
    end

    def project_models(configuration)
      ActiveRecord::Base.descendants.select do |klass|
        next unless configuration.model_enabled?(klass)

        project_klass?(klass) && connected?(klass)
      end
    end

    # Returns list of models to check
    def models(configuration)
      project_models(configuration).select do |klass|
        !klass.abstract_class? &&
          klass.table_exists? &&
          !klass.name.include?('HABTM_')
      end
    end

    def connected?(klass)
      klass.connection
    rescue ActiveRecord::ConnectionNotEstablished
      puts "#{klass} doesn't have active connection: ignoring"
      false
    end

    # Return list of not inherited models
    def parent_models(configuration)
      models(configuration).group_by(&:table_name).each_value.flat_map do |models|
        models.reject { |model| models.include?(model.superclass) }
      end
    end

    # @param klass [ActiveRecord::Base]
    #
    # @return [Boolean]
    def project_klass?(klass)
      return true unless Module.respond_to?(:const_source_location) && defined?(Bundler)

      !Module.const_source_location(klass.to_s).first.to_s.include?(Bundler.bundle_path.to_s)
    rescue NameError
      false
    end

    # @return [Boolean]
    def check_inclusion?(array, element)
      array.include?(element.to_s) || array.include?(element.to_sym)
    end

    def first_level_associations(model)
      associations = model.reflect_on_all_associations

      while model != ActiveRecord::Base && model.respond_to?(:reflect_on_all_associations)
        model = model.superclass
        associations -= model.reflect_on_all_associations
      end

      associations
    end

    # @return [Array<String>]
    def extract_index_columns(index_columns)
      return index_columns unless index_columns.is_a?(String)

      index_columns.split(',')
                   .map(&:strip)
                   .map { |str| str.gsub(/lower\(/i, 'lower(') }
                   .map { |str| str.gsub(/\(([^)]+)\)::\w+/, '\1') }
                   .map { |str| str.gsub(/'([^)]+)'::\w+/, '\1') }
    end

    def sorted_uniqueness_validator_columns(attribute, validator, model)
      uniqueness_validator_columns(attribute, validator, model).sort
    end

    def uniqueness_validator_columns(attribute, validator, model)
      ([wrapped_attribute_name(attribute, validator, model)] + scope_columns(validator, model)).map(&:to_s)
    end

    def scope_columns(validator, model)
      Array.wrap(validator.options[:scope]).map do |scope_item|
        foreign_key_or_attribute(model, scope_item)
      end
    end

    def foreign_key_or_attribute(model, attribute)
      model._reflect_on_association(attribute)&.foreign_key || attribute
    end

    # @return [String]
    def wrapped_attribute_name(attribute, validator, model)
      attribute = foreign_key_or_attribute(model, attribute)

      if validator.options[:case_sensitive].nil? || validator.options[:case_sensitive]
        attribute
      else
        "lower(#{attribute})"
      end
    end
  end
end
