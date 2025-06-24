# spec/requests/contests_admin_spec.rb
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests (admin flows)", type: :request do
  let(:admin)   { create(:user, :admin) }
  let(:user)    { create(:user) }
  let(:contest) { create(:contest, status: :live) }

  before do
    Flipper.enable(:contests)
    sign_in admin
  end

  # ------------------------------------------------------------------
  # ADMIN ACTIONS
  # ------------------------------------------------------------------
  describe "PATCH /contests/:contest_id/update_contest" do
    it "updates the deadline" do
      new_deadline = 2.weeks.from_now.change(usec: 0)

      patch "/contests/#{contest.id}/update_contest",
            params: { deadline: new_deadline.iso8601 }

      expect(response).to redirect_to("/contests/#{contest.id}")
      follow_redirect!
      expect(response.body).to include(I18n.l(new_deadline.to_date))
      expect(contest.reload.deadline.to_i).to eq new_deadline.to_i
    end

    it "rejects a deadline that is already past" do
      patch "/contests/#{contest.id}/update_contest",
            params: { deadline: 1.day.ago.iso8601 }

      expect(response).to redirect_to("/contests/admin")
      follow_redirect!
      expect(flash[:alert]).to eq "Deadline must be in the future."
    end
  end

  describe "PUT /contests/:contest_id/close_contest" do
    it "short-lists the winner and closes the contest" do
      allow(ShortlistContestWinner)
        .to receive(:new)
        .and_return(instance_double(ShortlistContestWinner, call: true))

      put "/contests/#{contest.id}/close_contest"

      expect(response).to redirect_to("/contests/#{contest.id}")
      follow_redirect!
      expect(response.body).to include("Contest was successfully ended.")
      expect(contest.reload).to be_completed
    end
  end

  describe "POST /contests/host" do
    it "creates a new live contest" do
      expect { post "/contests/host", params: {} }.to change(Contest, :count).by(1)

      follow_redirect!
      expect(response.body).to include("Contest was successfully started.")
    end
  end

  # ------------------------------------------------------------------
  # USER-FACING EDGE CASES
  # ------------------------------------------------------------------
  context "submission edge cases" do
    before { sign_in user }

    it "blocks submitting someone else’s project" do
      other_project = create(:project, author: admin)

      post "/contests/#{contest.id}/create_submission",
           params: {
             contest_id: contest.id,
             submission: { project_id: other_project.id }
           }

      expect(flash[:alert]).to eq "You can’t submit someone else’s project."
    end

    it "blocks a duplicate submission" do
      project = create(:project, author: user)
      create(:submission, contest: contest, project: project, user: user)

      post "/contests/#{contest.id}/create_submission",
           params: {
             contest_id: contest.id,
             submission: { project_id: project.id }
           }

      expect(flash[:notice]).to eq \
        "This project is already submitted in Contest ##{contest.id}"
    end
  end

  context "voting edge cases" do
    let(:project)    { create(:project, author: user) }
    let(:submission) { create(:submission, contest: contest, project: project) }

    before { sign_in user }

    it "blocks a second vote on the same submission" do
      SubmissionVote.create!(user: user, submission: submission, contest: contest)

      post "/contests/#{contest.id}/upvote/#{submission.id}"

      expect(flash[:notice]).to eq "You have already cast a vote for this submission!"
    end

    it "blocks voting after the user has spent all votes" do
      SubmissionVote::USER_VOTES_PER_CONTEST.times do
        another_sub = create(
          :submission,
          contest: contest,
          project: create(:project, author: user)
        )
        SubmissionVote.create!(user: user, submission: another_sub, contest: contest)
      end

      post "/contests/#{contest.id}/upvote/#{submission.id}"

      expect(flash[:notice]).to eq "You have used all your votes!"
    end
  end
end
