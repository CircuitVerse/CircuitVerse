# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest::SubmissionCardComponent, type: :component do
  it "shows project preview, vote count and action buttons" do
    contest    = create(:contest, :live)
    author     = create(:user)
    project    = create(:project, author: author)
    submission = create(:submission, contest: contest, project: project, submission_votes_count: 5)

    render_inline(described_class.new(submission: submission,
                                      contest:    contest,
                                      current_user: author))

    expect(page).to have_css("img.users-card-image[alt='#{project.name}']")
    expect(page).to have_text("Votes: 5")
    expect(page).to have_css("a.previewButton", text: "View")
    expect(page).to have_css("a.withdraw-button", text: "Withdraw")
  end
end
