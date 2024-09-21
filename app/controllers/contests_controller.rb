# frozen_string_literal: true

class ContestsController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :authenticate_user!, except: [:index]
  # GET /contests
  def index
    @contests = Contest.all.paginate(page: params[:page]).order("id DESC").limit(Contest.per_page)
    respond_to do |format|
      format.html
      format.json { render json: @contests }
      format.js
    end
  end

  # GET /contests/:id
  def show
    @contest = Contest.find(params[:id])
    @user_submission = @contest.submissions.where(user_id: current_user.id)
    @submissions = @contest.submissions.where.not(user_id: current_user.id).paginate(page: params[:page]).limit(6)
    @user_count = User.count
    return unless @contest.completed? && !Submission.where(contest_id: @contest.id).count.nil?

    @winner = ContestWinner.find_by(contest_id: @contest.id).submission
  end

  # GET /contests/admin
  def admin
    authorize Contest, :admin?
    @contests = Contest.all.paginate(page: params[:page]).order("id DESC").limit(Contest.per_page)
  end

  def update_deadline
    authorize Contest, :admin?
    @contest = Contest.find(params[:contest_id])
    new_deadline = params[:deadline].to_datetime

    if new_deadline <= Time.zone.now
      redirect_to contests_admin_path, notice: "Couldn't Update the deadline as Deadline must be in the future."
    else
      @contest.deadline = new_deadline

      if @contest.save
        redirect_to contest_page_path(@contest), notice: "Contest deadline was successfully updated."
      else
        redirect_to contests_admin_path,
                    alert: "Failed to update contest deadline: #{@contest.errors.full_messages.join(', ')}"
      end
    end
  end

  def close_contest
    authorize Contest, :admin?
    @contest = Contest.find(params[:contest_id])
    ShortlistContestWinner.new(@contest.id)
    @contest.deadline = Time.zone.now
    @contest.status = :completed
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
    authorize Contest, :admin?
    if concurrent_contest_exists?
      notice = "Concurrent contests are not allowed. Close other contests before creating a new one."
      redirect_to contests_admin_path, notice: notice
    else
      create_contest
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
      @submission.user_id = current_user.id
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
    if user_contest_votes >= 3
      notice = "You have used all your votes!"
    else
      vote = SubmissionVote.find_by(user_id: current_user.id, submission_id: params[:submission_id])
      if vote.nil?
        @submission_vote = SubmissionVote.new(user_id: current_user.id, submission_id: params[:submission_id],
                                              contest_id: params[:contest_id])
        @submission_vote.save!
        notice = "You have successfully voted the submission, Thanks! Votes remaining: #{2 - user_contest_votes}"
      else
        notice = "You have already vote this submission!"
      end
    end
    redirect_to contest_page_path(params[:contest_id]), notice: notice
  end
end

private

def concurrent_contest_exists?
  Contest.exists?(status: :live)
end

def create_contest
  @contest = Contest.new(deadline: 1.month.from_now, status: :live)

  respond_to do |format|
    if @contest.save
      ContestNotification.with(contest: @contest).deliver_later(User.all)
      format.html { redirect_to contest_page_path(@contest), notice: "Contest was successfully started." }
      format.json { render :show, status: :created, location: @contest }
    else
      format.html { render :admin }
      format.json { render json: @contest.errors, status: :unprocessable_entity }
    end
  end
end
