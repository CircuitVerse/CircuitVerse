# frozen_string_literal: true

module ForumHelper
  include SimpleDiscussion::ForumPostsHelper

  def formatted_content(text)
    options = {
      hard_wrap: true,
      filter_html: true,
      autolink: true,
      tables: true
    }
    md = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)
    sanitize(md.render(text))
  end
end
