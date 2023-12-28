# frozen_string_literal: true

module ProjectsHelper
  def auto_link_comments(comment)
        comment.body.gsub(URI::DEFAULT_PARSER.make_regexp, '<a href="\0" target="_blank">\0</a>').html_safe
  end
end
