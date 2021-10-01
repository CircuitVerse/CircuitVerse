# frozen_string_literal: true

require "active_model/attribute_set"
require "active_model/attribute/user_provided_default"

module ActiveModel
  module Attributes #:nodoc:
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    included do
      attribute_method_suffix "="
      class_attribute :attribute_types, :_default_attributes, instance_accessor: false
      self.attribute_types = Hash.new(Type.default_value)
      self._default_attributes = AttributeSet.new({})
    end

    module ClassMethods
      def attribute(name, type = Type::Value.new, **options)
        name = name.to_s
        if type.is_a?(Symbol)
          type = ActiveModel::Type.lookup(type, **options.except(:default))
        end
        self.attribute_types = attribute_types.merge(name => type)
        define_default_attribute(name, options.fetch(:default, NO_DEFAULT_PROVIDED), type)
        define_attribute_method(name)
      end

      # Returns an array of attribute names as strings
      #
      #   class Person
      #     include ActiveModel::Attributes
      #
      #     attribute :name, :string
      #     attribute :age, :integer
      #   end
      #
      #   Person.attribute_names
      #   # => ["name", "age"]
      def attribute_names
        attribute_types.keys
      end

      private
        def define_method_attribute=(name)
          ActiveModel::AttributeMethods::AttrNames.define_attribute_accessor_method(
            generated_attribute_methods, name, writer: true,
          ) do |temp_method_name, attr_name_expr|
            generated_attribute_methods.module_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{temp_method_name}(value)
                name = #{attr_name_expr}
                write_attribute(name, value)
              end
            RUBY
          end
        end

        NO_DEFAULT_PROVIDED = Object.new # :nodoc:
        private_constant :NO_DEFAULT_PROVIDED

        def define_default_attribute(name, value, type)
          self._default_attributes = _default_attributes.deep_dup
          if value == NO_DEFAULT_PROVIDED
            default_attribute = _default_attributes[name].with_type(type)
          else
            default_attribute = Attribute::UserProvidedDefault.new(
              name,
              value,
              type,
              _default_attributes.fetch(name.to_s) { nil },
            )
          end
          _default_attributes[name] = default_attribute
        end
    end

    def initialize(*)
      @attributes = self.class._default_attributes.deep_dup
      super
    end

    # Returns a hash of all the attributes with their names as keys and the values of the attributes as values.
    #
    #   class Person
    #     include ActiveModel::Model
    #     include ActiveModel::Attributes
    #
    #     attribute :name, :string
    #     attribute :age, :integer
    #   end
    #
    #   person = Person.new(name: 'Francesco', age: 22)
    #   person.attributes
    #   # => {"name"=>"Francesco", "age"=>22}
    def attributes
      @attributes.to_hash
    end

    # Returns an array of attribute names as strings
    #
    #   class Person
    #     include ActiveModel::Attributes
    #
    #     attribute :name, :string
    #     attribute :age, :integer
    #   end
    #
    #   person = Person.new
    #   person.attribute_names
    #   # => ["name", "age"]
    def attribute_names
      @attributes.keys
    end

    private
      def write_attribute(attr_name, value)
        name = attr_name.to_s
        name = self.class.attribute_aliases[name] || name

        @attributes.write_from_user(name, value)
        value
      end

      def attribute(attr_name)
        name = attr_name.to_s
        name = self.class.attribute_aliases[name] || name

        @attributes.fetch_value(name)
      end

      # Dispatch target for <tt>*=</tt> attribute methods.
      def attribute=(attribute_name, value)
        write_attribute(attribute_name, value)
      end
  end
end
