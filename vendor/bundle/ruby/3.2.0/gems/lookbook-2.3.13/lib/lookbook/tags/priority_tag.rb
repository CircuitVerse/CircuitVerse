module Lookbook
  class PriorityTag < YardTag
    DEFAULT_PRIORITY = 100000

    def value
      if text.present?
        int = text.to_i
        (int == 0) ? DEFAULT_PRIORITY : int
      else
        DEFAULT_PRIORITY
      end
    end

    alias_method :to_i, :value
  end
end
