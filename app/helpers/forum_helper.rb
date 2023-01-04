# frozen_string_literal: true

module ForumHelper
  include SimpleDiscussion::ForumPostsHelper

  def formatted_content(text)
    options = %I[hard_wrap filter_html autolink tables]
    md = Redcarpet.new(text, *options).to_html
    sanitize(md)
  end
end
