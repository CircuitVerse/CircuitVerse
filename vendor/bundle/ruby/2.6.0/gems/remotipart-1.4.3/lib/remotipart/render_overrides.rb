module Remotipart
  # Responder used to automagically wrap any non-xml replies in a text-area
  # as expected by iframe-transport.
  module RenderOverrides
    include ERB::Util
    include ActionView::Helpers::JavaScriptHelper

    def self.included(base)
      base.class_eval do
        # Use neither alias_method_chain nor prepend for compatibility
        alias render_without_remotipart render
        alias render render_with_remotipart
      end
    end

    def render_with_remotipart(*args, &block)
      render_return_value = render_without_remotipart(*args, &block)
      if remotipart_submitted?
        response.body = %{<script type="text/javascript">try{window.parent.document;}catch(err){document.domain=document.domain;}</script><textarea data-type="#{response.content_type}" data-status="#{response.response_code}" data-statusText="#{response.message}"></textarea><script type="text/javascript">document.querySelector("textarea").value="#{escape_javascript(response.body)}";</script>}
        response.content_type = ::Rails.version >= '5' ? Mime[:html] : Mime::HTML
        response_body
      else
        render_return_value
      end
    end
  end
end
