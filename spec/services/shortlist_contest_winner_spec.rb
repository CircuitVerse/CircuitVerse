# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShortlistContestWinner, type: :service do
  it "creates a ContestWinner record" do
    Flipper.enable(:contests)

    contest    = create(:contest, status: :live)
    project    = create(:project, project_access_type: "Public")
    submission = create(:submission, contest: contest, project: project)

    # Give the submission one vote so it's the top-ranked entry
    SubmissionVote.create!(user: project.author,
                           submission: submission,
                           contest: contest)

    expect do
      described_class.new(contest.id).call
    end.to change(ContestWinner, :count).by(1)
  end
end
