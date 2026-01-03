module Playwright
  # Each Impl class include this module.
  # Used for detecting whether the object is a XXXXImpl or not.
  module ApiImplementation ; end

  def self.define_api_implementation(class_name, &block)
    klass = Class.new
    klass.include(ApiImplementation)
    klass.class_eval(&block) if block
    if ::Playwright.const_defined?(class_name)
      raise ArgumentError.new("Playwright::#{class_name} already exist. Choose another class name.")
    end
    ::Playwright.const_set(class_name, klass)
  end
end

# load subclasses
Dir[File.join(__dir__, '*_impl.rb')].each { |f| require f }
