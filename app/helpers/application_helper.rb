# frozen_string_literal: true

module ApplicationHelper
  def render_markdown(text)
    sanitized_text = ActionController::Base.helpers.sanitize(text, tags: %w(p strong em a), attributes: %w(href))
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer, {})
    markdown.render(sanitized_text).html_safe
  end
end

