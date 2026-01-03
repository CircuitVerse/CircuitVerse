module Lookbook
  class TemplateError < Error
    def initialize(msg = nil, scope: "template", **kwargs)
      super
    end
  end
end
