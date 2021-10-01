module ActivityNotification
  # Provides extension of String class to help polymorphic implementation.
  module PolymorphicHelpers
    extend ActiveSupport::Concern

    included do
      class ::String
        # Convets to model instance.
        # @return [Object] Model instance
        def to_model_name
          singularize.camelize
        end

        # Convets to model class.
        # @return [Class] Model class
        def to_model_class
          to_model_name.classify.constantize
        end

        # Convets to singularized model name (resource name).
        # @return [String] Singularized model name (resource name)
        def to_resource_name
          singularize.underscore
        end

        # Convets to pluralized model name (resources name).
        # @return [String] Pluralized model name (resources name)
        def to_resources_name
          pluralize.underscore
        end

        # Convets to boolean.
        # Returns true for 'true', '1', 'yes', 'on' and 't'.
        # Returns false for 'false', '0', 'no', 'off' and 'f'.
        # @param [Boolean] default Default value to return when the String is not interpretable
        # @return [Boolean] Convered boolean value
        def to_boolean(default = nil)
          return true if ['true', '1', 'yes', 'on', 't'].include? self
          return false if ['false', '0', 'no', 'off', 'f'].include? self
          return default
        end
      end
    end

  end
end
