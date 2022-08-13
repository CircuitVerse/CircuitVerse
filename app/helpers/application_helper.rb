# frozen_string_literal: true

module ApplicationHelper
  def get_time_in_words(time)
    "#{time_ago_in_words(time)} ago, #{time.to_fs(:long)}"
  end
end
