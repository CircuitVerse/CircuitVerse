module Lookbook
  # Shared module that both Lookbook::Preview and ViewComponent::Preview are extended with
  module PreviewAfterRender
    def after_render(method:, html:, context:)
      instance = new
      if instance.method(method).arity > 1
        instance.send(method, html, context)
      else
        instance.send(method, html)
      end.html_safe
    end
  end
end
