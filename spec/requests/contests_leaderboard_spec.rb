# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /contests/:id/leaderboard", type: :request do
  let(:user)    { create(:user) }
  let(:contest) { create(:contest) }

  let!(:submission_old) do
    create(
      :submission,
      contest: contest,
      created_at: 2.days.ago,
      project: create(:project, name: "OldProject")
    )
  end

  let!(:submission_new) do
    create(
      :submission,
      contest: contest,
      created_at: 1.day.ago,
      project: create(:project, name: "NewProject")
    )
  end

  before do
    create_list(:submission_vote, 3, submission: submission_new, contest: contest)
    create_list(:submission_vote, 2, submission: submission_old, contest: contest)
  end

  context "when a user is signed in" do
    before { sign_in user }

    it "responds with HTTP 200" do
      get leaderboard_contest_path(contest)
      expect(response).to have_http_status(:ok)
    end

    it "lists submissions ordered by votes (desc) then created_at (asc)" do
      get leaderboard_contest_path(contest)

      body      = response.body
      new_pos   = body.index("NewProject")
      old_pos   = body.index("OldProject")

      expect(new_pos).to be < old_pos,
                         "Expected NewProject to appear before OldProject in the leaderboard HTML"
    end
  end

  context "when the contest cannot be found" do
    before { sign_in user }

    it "redirects back to the contests list with an alert" do
      get leaderboard_contest_path(-1)

      expect(response).to redirect_to(contests_path)
      expect(flash[:alert]).to eq "Contest not found."
    end
  end

  context "when not authenticated" do
    it "redirects to the Devise sign-in page" do
      get leaderboard_contest_path(contest)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
