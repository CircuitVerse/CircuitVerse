module BetterHtml::Helpers
  def html_attributes(args)
    BetterHtml::HtmlAttributes.new(args)
  end
end
