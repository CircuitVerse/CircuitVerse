# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest::ShowPageComponent, type: :component do
  it "shows the contest header" do
    contest = create(:contest, :completed)

    submissions      = contest.submissions.paginate(page: 1)
    user_submission  = submissions
    winner           = nil
    current_user     = build_stubbed(:user)

    render_inline(
      described_class.new(
        contest: contest,
        current_user: current_user,
        user_submissions: user_submission,
        submissions: submissions,
        winner: winner,
        user_count: 1,
        notice: nil
      )
    )

    expect(page).to have_text("Contest ##{contest.id}")
  end
end
