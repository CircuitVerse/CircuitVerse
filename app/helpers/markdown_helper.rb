# frozen_string_literal: true

module MarkdownHelper
  def markdown(text)
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text).html_safe
  end
end
