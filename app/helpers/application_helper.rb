# frozen_string_literal: true

module ApplicationHelper
  def render_markdown(text)
    sanitized_text = ActionController::Base.helpers.sanitize(text, tags: %w[p strong em a], attributes: %w[href])
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer, {})
    markdown_output = markdown.render(sanitized_text)
    ERB::Util.html_escape(markdown_output)
  end
end
