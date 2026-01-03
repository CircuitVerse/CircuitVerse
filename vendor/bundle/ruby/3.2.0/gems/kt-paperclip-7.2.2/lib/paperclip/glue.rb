require "paperclip/callbacks"
require "paperclip/validators"
require "paperclip/schema"

module Paperclip
  module Glue
    LOCALE_PATHS = Dir.glob("#{File.dirname(__FILE__)}/locales/*.{rb,yml}")

    def self.included(base)
      base.extend ClassMethods
      base.send :include, Callbacks
      base.send :include, Validators
      base.send :include, Schema if defined? ActiveRecord::Base

      I18n.load_path += LOCALE_PATHS unless (LOCALE_PATHS - I18n.load_path).empty?
    end
  end
end
