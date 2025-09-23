module Lookbook
  class AfterRenderTag < YardTag
    def value
      text.sub(/\A:/, "")
    end
  end
end
