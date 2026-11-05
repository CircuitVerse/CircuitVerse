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
      expect(page).to have_text("5 votes")
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
      expect(page).to have_text("0 votes")
      expect(page).to have_css("a.previewButton", text: "View")
      expect(page).not_to have_link("Withdraw")
    end
  end

  context "when the project has an ActiveStorage preview" do
    it "renders the circuit_preview image" do
      contest    = create(:contest, :live)
      project    = create(:project)
      submission = create(:submission, contest: contest, project: project)
      project.circuit_preview.attach(io: Rails.root.join("spec/fixtures/files/profile.png").open,
                                     filename: "preview.png", content_type: "image/png")

      render_inline described_class.new(submission: submission,
                                        contest: contest,
                                        current_user: nil)

      expect(page).to have_css("img[src^='/rails/active_storage/blobs/']")
    end
  end

  context "when contest is completed and current user is the author" do
    it "does not show Withdraw button" do
      contest    = create(:contest, status: :completed)
      author     = create(:user)
      project    = create(:project, author: author)
      submission = create(:submission,
                          contest: contest,
                          project: project,
                          submission_votes_count: 0)

      render_inline described_class.new(submission: submission,
                                        contest: contest,
                                        current_user: author)

      expect(page).to have_css("a.previewButton", text: "View")
      expect(page).not_to have_link("Withdraw")
    end
  end
end
