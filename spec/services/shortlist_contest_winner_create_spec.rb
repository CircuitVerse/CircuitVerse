# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShortlistContestWinner, "#create_winner_for internals" do
  let(:contest) { create(:contest, status: :live) }
  let(:submission) do
    create(:submission,
           contest: contest,
           project: create(:project, project_access_type: "Private"))
  end

  before do
    allow(FeaturedCircuit).to receive(:create!).and_return(true)
  end

  it "creates a ContestWinner record and flags the submission" do
    expect do
      described_class.new(contest.id).send(:create_winner_for, submission)
    end.to change(ContestWinner, :count).by(1)

    expect(submission.reload.winner).to be true
  end
end
