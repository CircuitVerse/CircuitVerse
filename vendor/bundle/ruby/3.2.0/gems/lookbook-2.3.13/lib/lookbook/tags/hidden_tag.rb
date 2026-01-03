module Lookbook
  class HiddenTag < YardTag
    def value
      text != "false"
    end

    def to_s
      value ? "true" : "false"
    end

    alias_method :to_bool, :value
  end
end
