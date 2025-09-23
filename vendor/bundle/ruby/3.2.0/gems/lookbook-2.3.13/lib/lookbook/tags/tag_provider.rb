module Lookbook
  class TagProvider < ::YARD::Tags::Tag
    def self.new(tag_name, text, types = nil, name = nil)
      tag_name = tag_name.to_s

      if tag_name == "custom"
        raise NameError.new "'custom' is a reserved tag name and cannot be used"
      end

      # Handle aliasing of removed `@component` tags
      tag_name = "renders" if tag_name == "component"

      begin
        tag_class = "Lookbook::#{tag_name.camelize}Tag".constantize
        tag_class.new(text)
      rescue NameError
        CustomTag.new(tag_name, text)
      end
    end
  end
end
