module Lookbook
  class PreviewTemplateError < Error
    def initialize(msg = nil, scope: "preview", **kwargs)
      super
    end
  end
end
