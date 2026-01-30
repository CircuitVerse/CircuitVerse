# frozen_string_literal: true

require 'psych'

module Psych
  class << self
    alias_method :original_load, :load if method_defined?(:load)
    alias_method :original_safe_load, :safe_load if method_defined?(:safe_load)
    
    def load(yaml, *args, **kwargs)
      if yaml.is_a?(String) && yaml.include?('ActiveSupport::HashWithIndifferentAccess')
        unsafe_load(yaml, *args, **kwargs)
      else
        original_load(yaml, *args, **kwargs)
      end
    rescue Psych::DisallowedClass => e
      if e.message.include?('ActiveSupport::HashWithIndifferentAccess')
        unsafe_load(yaml, *args, **kwargs)
      else
        raise e
      end
    end
    
    def safe_load(yaml, permitted_classes: [], aliases: false, **kwargs)
      permitted_classes = [
        ActiveSupport::HashWithIndifferentAccess,
        Symbol, Time, Hash, Array, String, Integer, Float,
        TrueClass, FalseClass, NilClass
      ] + Array(permitted_classes)
      
      begin
        original_safe_load(yaml, permitted_classes: permitted_classes, aliases: aliases, **kwargs)
      rescue Psych::DisallowedClass => e
        if e.message.include?('ActiveSupport::HashWithIndifferentAccess')
          unsafe_load(yaml, **kwargs)
        else
          raise e
        end
      end
    end
  end
end