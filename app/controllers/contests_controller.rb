# frozen_string_literal: true

class ContestsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  # before_action :authorize_admin, only: %i[admin]

  # GET /contests
  def index
    @contests = Contest.all.order(id: :desc)
  end

  # GET /contests/:id
  def show
    @contest = Contest.find(params[:id])
    @submissions = @contest.submissions
    @user_count = User.count
  end

  # GET /contests/admin
  def admin
    @contests = Contest.all.order(id: :desc)
  end

  def close_contest
    @contest = Contest.find(params[:id])
    @contest.deadline = Time.zone.now
    @contest.status = "Completed"
    respond_to do |format|
      if @contest.save
        format.html { redirect_to contest_page_path(@contest.id), notice: "Contest was successfully ended." }
        format.json { render :show, status: :created, location: @contest }
      else
        format.html { render :admin }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /contest/create
  def create
    # checking for any other live contest, if found mark is as completed
    Contest.all.each do |contest|
      if contest.status == "Live"
        contest.status = "Completed"
        contest.deadline = Time.zone.now
        contest.save
      end
    end
    @contest = Contest.new
    @contest.deadline = 1.month.from_now
    @contest.status = "Live"
    respond_to do |format|
      if @contest.save
        ContestNotification.with(contest: @contest).deliver_later(User.all)
        format.html { redirect_to contest_page_path(@contest.id), notice: "Contest was successfully started." }
        format.json { render :show, status: :created, location: @contest }
      else
        format.html { render :admin }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /contests/new_submission
  def new_submission
    @projects = current_user.projects
    @contest = Contest.find(params[:id])
    @submission = Submission.new
  end

  # POST /contests/:id/create_submission
  def create_submission
    is_submission = Submission.find_by(project_id: params[:submission][:project_id], contest_id: params[:contest_id])
    if is_submission.nil?
      @submission = Submission.new
      @submission.project_id = params[:submission][:project_id]
      @submission.contest_id = params[:contest_id]
      if @submission.save
        redirect_to contest_page_path(params[:contest_id]), notice: "Submission was successfully added."
      end
    else
      redirect_to new_submission_path, notice: "This project is already submitted in Contest ##{params[:contest_id]}"
    end
  end

  # PUT /contests/:contest_id/withdraw/:submission_id
  def withdraw
    @submission = Submission.find(params[:submission_id])
    @submission.destroy!
    redirect_to contest_page_path(params[:contest_id]), notice: "Submission was successfully removed."
  end

  # POST /contests/:contest_id/submission/:submission_id/upvote
  def upvote
    user_contest_votes = current_user.user_contest_votes(params[:contest_id])
    if user_contest_votes > 3
      notice = "You have used all your votes!"
    else
      vote = SubmissionVote.find_by(user_id: current_user.id, submission_id: params[:submission_id])
      if vote.nil?
        @submission_vote = SubmissionVote.new
        @submission_vote.user_id = current_user.id
        @submission_vote.submission_id = params[:submission_id]
        @submission_vote.contest_id = params[:contest_id]
        @submission_vote.save!
        notice = "You have successfully voted the submission, Thanks! Votes remaining: #{2 - user_contest_votes}"
      else
        notice = "You have already vote this submission!"
      end
    end
    redirect_to contest_page_path(params[:contest_id]), notice: notice
  end

  private

    def authorize_admin
      authorize Announcement.new, :admin?
    end
end