# frozen_string_literal: true

module ProjectsHelper
  def auto_link_comments(comment)
    sanitized_body = sanitize(comment.body, tags: %w[a], attributes: %w[href target])
    auto_link(sanitized_body).html_safe
  end
end
