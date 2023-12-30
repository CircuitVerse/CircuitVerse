# frozen_string_literal: true

module ProjectsHelper
  def auto_link_comments(comment)
    escaped_body = h(comment.body)
    sanitized_body = sanitize(escaped_body)
    auto_linked_body = sanitized_body.gsub(URI::DEFAULT_PARSER.make_regexp, '<a href="\0" target="_blank">\0</a>')
    raw(auto_linked_body)
  end
end







