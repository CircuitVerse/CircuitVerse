# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest::SubmissionCardComponent, type: :component do
  context "when current user is the author" do
    it "shows project preview, vote count and both action buttons" do
      contest    = create(:contest, :live)
      author     = create(:user)
      project    = create(:project, author: author)
      submission = create(:submission,
                          contest: contest,
                          project: project,
                          submission_votes_count: 5)

      render_inline described_class.new(submission: submission,
                                        contest: contest,
                                        current_user: author)

      expect(page).to have_css("img[alt='#{project.name}']")
      expect(page).to have_text("Votes: 5")
      expect(page).to have_css("a.previewButton", text: "View")
      expect(page).to have_link("Withdraw")
    end
  end

  context "when current user is not the author" do
    it "does not show Withdraw button" do
      contest    = create(:contest, :live)
      author     = create(:user)
      viewer     = create(:user)
      project    = create(:project, author: author)
      submission = create(:submission,
                          contest: contest,
                          project: project,
                          submission_votes_count: 0)

      render_inline described_class.new(submission: submission,
                                        contest: contest,
                                        current_user: viewer)

      expect(page).to have_css("img[alt='#{project.name}']")
      expect(page).to have_text("Votes: 0")
      expect(page).to have_css("a.previewButton", text: "View")
      expect(page).not_to have_link("Withdraw")
    end
  end
end
