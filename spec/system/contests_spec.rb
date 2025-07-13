# frozen_string_literal: true

require "rails_helper"

describe "Contests", type: :system do
  before do
    @contest = FactoryBot.create(:contest, status: :live)
    @user    = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: @user)
    Flipper.enable(:contests)
    sign_in @user
  end

  let(:create_params) do
    {
      contest_id: @contest.id,
      submission: { project_id: @project.id }
    }
  end

  it "list all the contest" do
    visit contests_path
    check_contest_container(@contest.id, "LIVE", @contest.submissions.count)

    expect(page).to have_text("Contest ##{@contest.id}")
  end

  it "redirects to contest" do
    visit contests_path
    page.find("#contest-#{@contest.id}").click
    check_contest_page(@contest.id)

    expect(page).to have_current_path(contest_path(@contest.id))
  end

  context "contest submission" do
    before do
      visit contest_path(@contest.id)
      page.find(".contest-submission-button").click
    end

    it "render the project submission page and submit the project" do
      expect(page).to have_text("Project Submission")
      expect(page).to have_text(@project.name)

      page.find("#submission_project_id_#{@project.id}").click
      page.find("#submission-submit-button").click
      expect(page).to have_text("Submission was successfully added.")
      expect(@contest.submissions.count).to eq(1)
      check_submission_container(@contest.submissions.first, @project)
    end

    it "does not submit the same project for a contest again." do
      page.find("#submission_project_id_#{@project.id}").click
      page.find("#submission-submit-button").click
      page.find(".contest-submission-button").click
      page.find("#submission_project_id_#{@project.id}").click
      page.find("#submission-submit-button").click

      expect(page).to have_text("This project is already submitted in Contest ##{@contest.id}")
    end
  end

  context "withdraw submission" do
    before do
      visit new_contest_submission_path(@contest.id)
      page.find("#submission_project_id_#{@project.id}").click
      page.find("#submission-submit-button").click
    end

    it "withdraw the submission" do
      page.find("#withdraw-submission-#{@contest.submissions.last.id}").click
      expect(page).to have_text("Withdraw Submission")
      expect(page).to have_text("Are you sure you want to withdraw your submission from contest?")

      page.find("#withdraw-submission-button").click
      expect(page).to have_text("Submission was successfully removed.")
      expect(@contest.submissions.count).to eq(0)
    end
  end

  context "when user votes the submission" do
    before do
      visit new_contest_submission_path(@contest.id)
      page.find("#submission_project_id_#{@project.id}").click
      page.find("#submission-submit-button").click
      sign_in_random_user
      visit contest_path(@contest.id)
    end

    it "votes the submission" do
      page.find("#vote-submission-#{@contest.submissions.last.id}").click
      expect(page).to have_text("You have successfully voted the submission, Thanks! Votes remaining: 2")
      expect(@contest.submissions.last.submission_votes_count).to eq(1)
    end
  end

  context "when user try to vote the submission again" do
    before do
      visit new_contest_submission_path(@contest.id)
      page.find("#submission_project_id_#{@project.id}").click
      page.find("#submission-submit-button").click
      sign_in_random_user
      visit contest_path(@contest.id)
      page.find("#vote-submission-#{@contest.submissions.last.id}").click
    end

    it "does not vote the submission again" do
      page.find("#vote-submission-#{@contest.submissions.last.id}").click
      expect(page).to have_text("You have already cast a vote for this submission!")
      expect(@contest.submissions.last.submission_votes_count).to eq(1)
    end
  end

  def check_submission_container(submission, project)
    expect(page).to have_text(project.name)
    expect(page).to have_text("Votes: #{submission.submission_votes_count}")
  end

  def check_contest_page(id)
    expect(page).to have_text("Contest ##{id}")
    expect(page).to have_text("Your Remaining Votes: 3")
  end

  def check_contest_container(id, status, entries)
    expect(page).to have_text("Contest ##{id}")
    expect(page).have_text(status)
    expect(page).to have_text("Entries: #{entries}")
  end
end
