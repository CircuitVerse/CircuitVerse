# frozen_string_literal: true

module ContestsHelper
  include ActionView::Helpers::DateHelper

  def contest_time_left(contest)
    return t("contest.timer.expired") if contest.deadline.blank? || contest.deadline <= Time.current

    distance_of_time_in_words(Time.current, contest.deadline)
  end
end
