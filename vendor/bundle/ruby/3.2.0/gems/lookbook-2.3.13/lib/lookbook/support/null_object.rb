module Lookbook
  class NullObject < BasicObject
    def method_missing(*)
    end

    def respond_to_missing?(name)
      true
    end
  end
end
