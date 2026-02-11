module Utf8Sanitizer
  extend ActiveSupport::Concern

  class_methods do
    def sanitize_utf8(value)
      return value unless value.is_a?(String)

      value.encode(
        Encoding::UTF_8,
        invalid: :replace,
        undef: :replace,
        replace: ""
      )
    end
  end

  def sanitize_utf8(value)
    self.class.sanitize_utf8(value)
  end
end
