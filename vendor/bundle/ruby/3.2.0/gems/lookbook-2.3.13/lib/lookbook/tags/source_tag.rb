module Lookbook
  class SourceTag < YardTag
    def value
      resolve_path(text.strip) if text.present?
    end
  end
end
