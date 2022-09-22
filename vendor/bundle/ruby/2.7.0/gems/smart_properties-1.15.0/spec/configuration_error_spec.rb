require 'spec_helper'

RSpec.describe SmartProperties, 'configuration error' do
  subject(:klass) { DummyClass.new }

  context "when defining a property with invalid configuration options" do
    it "should report all invalid options" do
      invalid_property_definition = lambda do
        klass.class_eval do
          property :title, invalid_option_1: 'boom', invalid_option_2: 'boom', invalid_option_3: 'boom'
        end
      end

      expect(&invalid_property_definition).to raise_error(SmartProperties::ConfigurationError, "SmartProperties do not support the following configuration options: invalid_option_1, invalid_option_2, invalid_option_3.")
    end

    it "should not accept default values that may be mutated" do
      invalid_property_definition = lambda do
        klass.class_eval do
          property :title, default: []
        end
      end

      expect(&invalid_property_definition).to(
        raise_error(SmartProperties::ConfigurationError,
          "Default attribute value [] cannot be specified as literal, "\
            "use the syntax `default: -> { ... }` instead.")
      )
    end
  end
end
