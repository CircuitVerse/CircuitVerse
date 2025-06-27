# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContestsController, type: :controller do
  include Rails.application.routes.url_helpers

  let(:admin)   { create(:user, admin: true) }
  let(:user)    { create(:user) }
  let!(:contest) { create(:contest, status: :live) } # existing live contest

  before { Flipper.enable(:contests) }

  describe "#show" do
    it "renders the contest page" do
      sign_in user
      get :show, params: { id: contest.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update_deadline" do
    it "updates the deadline when admin" do
      sign_in admin
      put :update_deadline,
          params: { contest_id: contest.id,
                    deadline: 2.days.from_now.strftime("%Y-%m-%d %H:%M") }
      expect(response).to redirect_to(contest_page_path(contest))
    end
  end

  describe "#close_contest" do
    it "marks contest completed" do
      sign_in admin
      put :close_contest, params: { contest_id: contest.id }
      expect(response).to redirect_to(contest_page_path(contest))
      expect(contest.reload).to be_completed
    end
  end

  describe "#create" do
    it "creates a new contest" do
      contest.update!(status: :completed) # avoid 'concurrent contest' guard
      sign_in admin
      post :create, params: { contest: {} } # send no unknown attrs
      expect(response).to redirect_to(contest_page_path(Contest.order(:id).last))
    end
  end

  describe "#create_submission" do
    it "lets a user submit their project" do
      project = create(:project, author: user)
      sign_in user
      post :create_submission,
           params: { id: contest.id,
                     contest_id: contest.id,
                     submission: { project_id: project.id } }
      expect(response).to redirect_to(contest_page_path(contest))
    end
  end

  describe "#upvote" do
    it "allows a user to vote on a submission" do
      submission = create(:submission, contest: contest, user: user)
      voter = create(:user)
      sign_in voter
      post :upvote,
           params: { contest_id: contest.id,
                     submission_id: submission.id }
      expect(response).to redirect_to(contest_page_path(contest))
    end
  end

  describe "feature-flag gate" do
    it "redirects when contests flag is disabled" do
      Flipper.disable(:contests)
      sign_in user
      get :new_submission, params: { id: contest.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "#redirect_unauthorized_project" do
    it "blocks submitting someone else's project" do
      foreign_project = create(:project) # owned by another user
      sign_in user
      post :create_submission,
           params: { id: contest.id,
                     contest_id: contest.id,
                     submission: { project_id: foreign_project.id } }
      expect(response).to redirect_to(contest_page_path(contest))
      expect(flash[:alert]).to eq("You can’t submit someone else’s project.")
    end
  end
end
