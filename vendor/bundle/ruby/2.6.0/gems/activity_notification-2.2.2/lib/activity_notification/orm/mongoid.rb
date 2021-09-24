module ActivityNotification
  module Association
    extend ActiveSupport::Concern

    included do
      # Selects filtered notifications by associated instance.
      # @scope class
      # @param [String] name     Association name
      # @param [Object] instance Associated instance
      # @return [Mongoid::Criteria<Notificaion>] Database query of filtered notifications
      scope :filtered_by_association, ->(name, instance) { where("#{name}_id" => instance.present? ? instance.id : nil, "#{name}_type" => instance.present? ? instance.class.name : nil) }
    end

    class_methods do
      # Defines has_many association with ActivityNotification models.
      # @return [Mongoid::Criteria<Object>] Database query of associated model instances
      def has_many_records(name, options = {})
        has_many_polymorphic_xdb_records name, options
      end

      # Defines polymorphic belongs_to association with models in other database.
      def belongs_to_polymorphic_xdb_record(name, _options = {})
        association_name     = name.to_s.singularize.underscore
        id_field, type_field = "#{association_name}_id", "#{association_name}_type"
        field id_field,   type: String
        field type_field, type: String
        associated_record_field = "stored_#{association_name}"
        field associated_record_field, type: Hash if ActivityNotification.config.store_with_associated_records && _options[:store_with_associated_records]

        self.instance_eval do
          define_method(name) do |reload = false|
            reload and self.instance_variable_set("@#{name}", nil)
            if self.instance_variable_get("@#{name}").blank?
              if (class_name = self.send(type_field)).present?
                object_class = class_name.classify.constantize
                self.instance_variable_set("@#{name}", object_class.where(id: self.send(id_field)).first)
              end
            end
            self.instance_variable_get("@#{name}")
          end

          define_method("#{name}=") do |new_instance|
            if new_instance.nil? then instance_id, instance_type = nil, nil else instance_id, instance_type = new_instance.id, new_instance.class.name end
            self.send("#{id_field}=", instance_id)
            self.send("#{type_field}=", instance_type)
            associated_record_json = new_instance.as_json(_options[:as_json_options] || {})
            # Cast Hash $oid field to String id to handle BSON::String::IllegalKey
            if associated_record_json.present?
              associated_record_json.each do |k, v|
                associated_record_json[k] = v['$oid'] if v.is_a?(Hash) && v.has_key?('$oid')
              end
            end
            self.send("#{associated_record_field}=", associated_record_json) if ActivityNotification.config.store_with_associated_records && _options[:store_with_associated_records]
            self.instance_variable_set("@#{name}", nil)
          end
        end
      end

      # Defines polymorphic has_many association with models in other database.
      # @todo Add dependent option
      def has_many_polymorphic_xdb_records(name, options = {})
        association_name     = options[:as] || name.to_s.underscore
        id_field, type_field = "#{association_name}_id", "#{association_name}_type"
        object_name          = options[:class_name] || name.to_s.singularize.camelize
        object_class         = object_name.classify.constantize

        self.instance_eval do
          define_method(name) do |reload = false|
            reload and self.instance_variable_set("@#{name}", nil)
            if self.instance_variable_get("@#{name}").blank?
              new_value = object_class.where(id_field => self.id, type_field => self.class.name)
              self.instance_variable_set("@#{name}", new_value)
            end
            self.instance_variable_get("@#{name}")
          end
        end
      end
    end
  end
end

# Monkey patching for Mongoid::Document as_json
module Mongoid
  # Monkey patching for Mongoid::Document as_json
  module Document
    # Monkey patching for Mongoid::Document as_json
    # @param [Hash] options Options parameter
    # @return [Hash] Hash representing the model
    def as_json(options = {})
      json = super(options)
      json["id"] = json["_id"].to_s.start_with?("{\"$oid\"=>") ? self.id.to_s : json["_id"].to_s
      if options.has_key?(:include)
        case options[:include]
        when Symbol then json[options[:include].to_s] = self.send(options[:include]).as_json
        when Array  then options[:include].each {|model| json[model.to_s] = self.send(model).as_json }
        when Hash   then options[:include].each {|model, options| json[model.to_s] = self.send(model).as_json(options) }
        end
      end
      json
    end
  end
end

require_relative 'mongoid/notification.rb'
require_relative 'mongoid/subscription.rb'
