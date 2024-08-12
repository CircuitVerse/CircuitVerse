# frozen_string_literal: true

module QuestionsHelper
  def truncated_markdown(statement, length = 100)
    plain_text = strip_tags(statement)
    truncated_text = truncate(plain_text, length: length, separator: " ")
    markdown(truncated_text)
  end
end
