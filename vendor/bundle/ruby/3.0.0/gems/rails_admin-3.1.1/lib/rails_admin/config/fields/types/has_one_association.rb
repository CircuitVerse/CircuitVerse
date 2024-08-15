# frozen_string_literal: true

require 'rails_admin/config/fields/association'

module RailsAdmin
  module Config
    module Fields
      module Types
        class HasOneAssociation < RailsAdmin::Config::Fields::Association
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types.register(self)

          register_instance_option :filter_operators do
            %w[_discard like not_like is starts_with ends_with] + (required? ? [] : %w[_separator _present _blank])
          end

          register_instance_option :partial do
            nested_form ? :form_nested_one : :form_filtering_select
          end

          # Accessor for field's formatted value
          register_instance_option :formatted_value do
            (o = value) && o.send(associated_model_config.object_label_method)
          end

          def selected_id
            value.try(:id).try(:to_s)
          end

          def method_name
            nested_form ? "#{name}_attributes".to_sym : super
          end

          def multiple?
            false
          end

          def associated_prepopulate_params
            {associated_model_config.abstract_model.param_key => {association.foreign_key => bindings[:object].try(:id)}}
          end
        end
      end
    end
  end
end
