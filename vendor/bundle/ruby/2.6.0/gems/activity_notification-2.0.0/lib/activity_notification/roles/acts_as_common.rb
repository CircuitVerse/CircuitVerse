module ActivityNotification
  # Common module included in acts_as module.
  # Provides methods to extract parameters.
  module ActsAsCommon
    extend ActiveSupport::Concern

    class_methods do
      protected
        # Sets acts_as parameters.
        # @api protected
        def set_acts_as_parameters(option_list, options, field_prefix = "")
          option_list.map { |key|
            options[key] ?
              [key, self.send("_#{field_prefix}#{key}=".to_sym, options.delete(key))] : [nil, nil]
          }.to_h.delete_if { |k, _| k.nil? }
        end
  
        # Sets acts_as parameters for target.
        # @api protected
        def set_acts_as_parameters_for_target(target_type, option_list, options, field_prefix = "")
          option_list.map { |key|
            options[key] ?
              [key, self.send("_#{field_prefix}#{key}".to_sym).store(target_type.to_sym, options.delete(key))] : [nil, nil]
          }.to_h.delete_if { |k, _| k.nil? }
        end
    end
  end
end