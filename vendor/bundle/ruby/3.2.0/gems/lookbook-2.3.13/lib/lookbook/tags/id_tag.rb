module Lookbook
  class IdTag < YardTag
    def value
      Utils.id(text) if text.present?
    end
  end
end
