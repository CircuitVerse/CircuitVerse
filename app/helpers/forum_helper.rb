# frozen_string_literal: true

module ForumHelper
  def formatted_content(text)
    options = %i[hard_wrap filter_html autolink tables]
    Redcarpet.new(text, *options).to_html
  end
end
