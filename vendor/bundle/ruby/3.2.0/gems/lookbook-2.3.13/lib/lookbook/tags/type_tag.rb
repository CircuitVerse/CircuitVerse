module Lookbook
  class TypeTag < YardTag
    def value
      text.downcase.to_sym
    end
  end
end
