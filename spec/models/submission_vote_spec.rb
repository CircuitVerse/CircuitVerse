# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubmissionVote, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:submission) }
    it { is_expected.to belong_to(:contest) }
  end

  describe "validations" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:contest) { create(:contest) }
    let(:project) { create(:project, author: user) }
    let(:submission) { create(:submission, contest: contest, project: project, user: user) }

    it "is invalid if user votes for their own submission" do
      vote = build(:submission_vote, user: user, submission: submission, contest: contest)
      expect(vote).not_to be_valid
      expect(vote.errors[:base]).to include("You cannot vote for your own submission")
    end

    it "is invalid if project author votes for another user's submission" do
      submission_by_other_user = create(:submission, contest: contest, project: project, user: other_user)
      vote = build(:submission_vote, user: user, submission: submission_by_other_user, contest: contest)
      expect(vote).not_to be_valid
      expect(vote.errors[:base]).to include("You cannot vote for your own submission")
    end

    it "is valid when voting for another user's submission" do
      vote = build(:submission_vote, user: other_user, submission: submission, contest: contest)
      expect(vote).to be_valid
    end
  end
end
