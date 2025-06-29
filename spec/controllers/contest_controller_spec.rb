# frozen_string_literal: true

require "rails_helper"

describe ContestsController, type: :request do
  before do
    @user    = FactoryBot.create(:user, admin: true)
    @contest = FactoryBot.create(:contest, status: :live)
    @project = FactoryBot.create(:project, author: @user)
    sign_in @user
  end

  let(:create_params) do
    {
      contest_id: @contest.id,
      submission: {
        project_id: @project.id
      }
    }
  end

  describe "#index" do
    it "renders all the contests" do
      get contests_path
      expect(Contest.count).to eq(1)
    end
  end

  describe "#show" do
    it "render the contest page" do
      get contest_page_path(@contest.id)
      expect(response.status).to eq(200)
      expect(@contest.status).to eq("live")
    end
  end

  describe "#close_contest" do
    it "close the live contest" do
      get contests_admin_path
      post new_contest_path
      expect(response.status).to eq(302)

      new_contest = Contest.find_by(status: "live")
      put close_contest_path(new_contest.id)

      expect(response.status).to eq(302)
      expect(new_contest.reload.status).to eq("completed")
      expect(Contest.where(status: "live").count).to eq(0)
    end
  end

  describe "#create" do
    before do
      put close_contest_path(@contest.id)
      get contests_admin_path
    end

    context "when there is not live contest" do
      it "creates a new contest" do
        post new_contest_path

        expect(response.status).to eq(302)
        expect(Contest.where(status: "live").count).to eq(1)
      end
    end

    context "when there is live contest" do
      before do
        post new_contest_path
      end

      it "does not allow to create concurrent live contest" do
        expect do
          post new_contest_path
        end.not_to change(Contest.where(status: "live"), :count)
      end
    end
  end

  describe "#new_submission" do
    it "renders new submission form template" do
      get new_submission_path(@contest.id)
      expect(response.body).to include("Project Submission")
    end
  end

  describe "#create_submission" do
    context "when new project is selected for submission" do
      it "creates a new submission" do
        post create_submission_path(@contest.id), params: create_params

        expect(response.status).to eq(302)
        expect(@contest.submissions.count).to eq(1)
      end
    end

    context "when the project is already submitted." do
      before do
        post create_submission_path(@contest.id), params: create_params
      end

      it "not creates a new submission" do
        expect do
          post create_submission_path(@contest.id), params: create_params
        end.not_to change(Submission, :count)
      end
    end
  end

  describe "#withdraw" do
    before do
      @project = FactoryBot.create(:project, author: @user)
      post create_submission_path(@contest.id), params: create_params
      @submission = Submission.last
    end

    it "withdraw user submission from contest" do
      delete withdraw_submission_path(@contest.id, @submission.id)

      expect(@contest.submissions.count).to eq(0)
    end
  end

  describe "#upvote" do
    before do
      post create_submission_path(@contest.id), params: create_params
      @submission = Submission.last
    end

    context "when a user votes the submission for first time" do
      it "votes the submission successfully" do
        sign_in_random_user
        get contest_page_path(@contest.id)

        expect do
          post vote_submission_path(@contest.id, @submission.id)
        end.to change(@submission.submission_votes, :count).by(1)
      end
    end

    context "when a user already voted the submission" do
      it "not vote the submission again" do
        sign_in_random_user
        get contest_page_path(@contest.id)
        post vote_submission_path(@contest.id, @submission.id)

        expect do
          post vote_submission_path(@contest.id, @submission.id)
        end.not_to change(@submission.submission_votes, :count)
      end
    end
  end
end
