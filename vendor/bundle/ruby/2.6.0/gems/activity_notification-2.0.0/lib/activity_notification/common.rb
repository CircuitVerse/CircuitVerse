module ActivityNotification

  # Used to transform value from metadata to data.
  # Accepts Symbols, which it will send against context.
  # Accepts Procs, which it will execute with controller and context.
  # Both Symbols and Procs will be passed arguments of this method.
  # Also accepts Hash of these Symbols or Procs.
  # If any other value will be passed, returns original value.
  #
  # @param [Object] context Context to resolve parameter, which is usually target or notificable model
  # @param [Symbol, Proc, Hash, Object] thing Symbol or Proc to resolve parameter
  # @param [Array] args Arguments to pass to thing as method
  # @return [Object] Resolved parameter value
  def self.resolve_value(context, thing, *args)
    case thing
    when Symbol
      symbol_method = context.method(thing)
      if symbol_method.arity > 1
        symbol_method.call(ActivityNotification.get_controller, *args)
      elsif symbol_method.arity > 0
        symbol_method.call(ActivityNotification.get_controller)
      else
        symbol_method.call
      end
    when Proc
      if thing.arity > 2
        thing.call(ActivityNotification.get_controller, context, *args)
      elsif thing.arity > 1
        thing.call(ActivityNotification.get_controller, context)
      elsif thing.arity > 0
        thing.call(context)
      else
        thing.call
      end
    when Hash
      thing.dup.tap do |hash|
        hash.each do |key, value|
          hash[key] = ActivityNotification.resolve_value(context, value, *args)
        end
      end
    else
      thing
    end
  end

  # Casts to indifferent hash
  # @param [ActionController::Parameters, Hash] hash
  # @return [HashWithIndifferentAccess] Converted indifferent hash
  def self.cast_to_indifferent_hash(hash = {})
    # This is the typical (not-ActionView::TestCase) code path.
    hash = hash.to_unsafe_h if hash.respond_to?(:to_unsafe_h)
    # In Rails 5 to_unsafe_h returns a HashWithIndifferentAccess, in Rails 4 it returns Hash
    hash = hash.with_indifferent_access if hash.instance_of? Hash
    hash
  end

  # Common module included in target and notifiable model.
  # Provides methods to resolve parameters from configured field or defined method.
  # Also provides methods to convert into resource name or class name as string.
  module Common

    # Used to transform value from metadata to data which belongs model instance.
    # Accepts Symbols, which it will send against this instance,
    # Accepts Procs, which it will execute with this instance.
    # Both Symbols and Procs will be passed arguments of this method.
    # Also accepts Hash of these Symbols or Procs.
    # If any other value will be passed, returns original value.
    #
    # @param [Symbol, Proc, Hash, Object] thing Symbol or Proc to resolve parameter
    # @param [Array] args Arguments to pass to thing as method
    # @return [Object] Resolved parameter value
    def resolve_value(thing, *args)
      case thing
      when Symbol
        symbol_method = method(thing)
        if symbol_method.arity > 0
          symbol_method.call(*args)
        else
          symbol_method.call
        end
      when Proc
        if thing.arity > 1
          thing.call(self, *args)
        elsif thing.arity > 0
          thing.call(self)
        else
          thing.call
        end
      when Hash
        thing.dup.tap do |hash|
          hash.each do |key, value|
            hash[key] = resolve_value(value, *args)
          end
        end
      else
        thing
      end
    end

    # Convets to class name.
    # @return [String] Class name
    def to_class_name
      self.class.name
    end

    # Convets to singularized model name (resource name).
    # @return [String] Singularized model name (resource name)
    def to_resource_name
      self.to_class_name.demodulize.singularize.underscore
    end

    # Convets to pluralized model name (resources name).
    # @return [String] Pluralized model name (resources name)
    def to_resources_name
      self.to_class_name.demodulize.pluralize.underscore
    end

    # Convets to printable model type name to be humanized.
    # @return [String] Printable model type name
    # @todo Is this the best to make readable?
    def printable_type
      "#{self.to_class_name.demodulize.humanize}"
    end

    # Convets to printable model name to show in view or email.
    # @return [String] Printable model name
    def printable_name
      "#{self.printable_type} (#{id})"
    end
  end
end