# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class ContestsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :check_contests_feature_flag
  before_action :set_user_count, only: :show

  # GET /contests
  def index
    @contests = Contest
                .order(id: :desc)
                .paginate(page: params[:page])
                .limit(Contest.per_page)

    respond_to do |format|
      format.html
      format.json { render json: @contests }
      format.js
    end
  end

  # GET /contests/:id
  def show
    @contest         = Contest.find(params[:id])
    @user_submission = @contest.submissions.where(user_id: current_user&.id)
    @submissions     = @contest.submissions
                               .where.not(user_id: current_user&.id)
                               .paginate(page: params[:page])
                               .limit(6)

    return unless @contest.completed? && Submission.exists?(contest_id: @contest.id)

    contest_winner = ContestWinner.find_by(contest_id: @contest.id)
    return if contest_winner.nil?

    @winner = contest_winner.submission
  end

  # GET /contests/admin
  def admin
    authorize Contest, :admin?
    @contests = Contest
                .order(id: :desc)
                .paginate(page: params[:page])
                .limit(Contest.per_page)
  end

  # PUT /contests/:contest_id/update_deadline
  def update_deadline
    authorize Contest, :admin?
    @contest = Contest.find(params[:contest_id])

    parsed_deadline = parse_deadline_or_redirect(params[:deadline])
    return if performed?

    if parsed_deadline <= Time.zone.now
      return redirect_to(contests_admin_path,
                         alert: "Deadline must be in the future.")
    end

    if @contest.update(deadline: parsed_deadline)
      redirect_to contest_page_path(@contest), notice: "Contest deadline was successfully updated."
    else
      redirect_to contests_admin_path,
                  alert: "Failed to update contest deadline: #{@contest.errors.full_messages.join(', ')}"
    end
  end

  # PUT /contests/:contest_id/close_contest
  def close_contest
    authorize Contest, :admin?

    @contest = Contest.find(params[:contest_id])
    ShortlistContestWinner.new(@contest.id).call

    if @contest.update(
      deadline: Time.zone.now,
      status: :completed
    )
      redirect_to contest_page_path(@contest),
                  notice: "Contest was successfully ended."
    else
      render :admin, status: :unprocessable_entity
    end
  end

  # POST /contest/create
  # rubocop:disable Metrics/MethodLength
  def create
    authorize Contest, :admin?

    if concurrent_contest_exists?
      redirect_to contests_admin_path,
                  notice: "Concurrent contests are not allowed. Close other contests before creating a new one."
      return
    end

    @contest = Contest.new(
      contest_params.reverse_merge(
        deadline: 1.month.from_now,
        status: :live
      )
    )

    if @contest.save
      User.find_each(batch_size: 1_000) do |user|
        ContestNotification.with(contest: @contest).deliver_later(user)
      end
      redirect_to contest_page_path(@contest),
                  notice: "Contest was successfully started."
    else
      render :admin, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/MethodLength

  # GET /contests/:id/new_submission
  def new_submission
    @projects   = current_user.projects
    @contest    = Contest.find(params[:id])
    @submission = Submission.new
  end

  # POST /contests/:id/create_submission
  def create_submission
    project_id = params[:submission][:project_id]

    return redirect_unauthorized_project unless project_owner?(project_id)
    return redirect_duplicate_submission if duplicate_submission?(project_id)

    @submission = Submission.new(
      project_id: project_id,
      contest_id: params[:contest_id],
      user_id: current_user.id
    )

    if @submission.save
      redirect_to contest_page_path(params[:contest_id]),
                  notice: "Submission was successfully added."
    else
      render :new_submission, status: :unprocessable_entity
    end
  end

  # PUT /contests/:contest_id/withdraw/:submission_id
  def withdraw
    submission = find_withdrawable_submission
    submission.destroy!
    redirect_to contest_page_path(params[:contest_id]),
                notice: "Submission was successfully removed."
  end

  # POST /contests/:contest_id/submission/:submission_id/upvote
  # rubocop:disable Metrics/MethodLength
  def upvote
    contest = Contest.find(params[:contest_id])
    redirect_to contest_page_path(contest), alert: "Voting is closed." and return if contest.completed?

    user_votes = current_user.votes_for_contest(contest.id)

    notice = if user_votes >= SubmissionVote::USER_VOTES_PER_CONTEST
      "You have used all your votes!"
    elsif SubmissionVote.exists?(
      user_id: current_user.id,
      submission_id: params[:submission_id]
    )
      "You have already cast a vote for this submission!"
    else
      SubmissionVote.create!(
        user_id: current_user.id,
        submission_id: params[:submission_id],
        contest_id: contest.id
      )
      "You have successfully voted the submission, Thanks! Votes remaining: " \
        "#{SubmissionVote::USER_VOTES_PER_CONTEST - 1 - user_votes}"
    end

    redirect_to contest_page_path(contest), notice: notice
  end
  # rubocop:enable Metrics/MethodLength

  private

    def parse_deadline_or_redirect(str)
      parsed = Time.zone.parse(str)
      redirect_to(contests_admin_path, alert: "Invalid deadline format.") and return if parsed.nil?

      parsed
    end

    def project_owner?(project_id)
      current_user.projects.exists?(id: project_id)
    end

    def duplicate_submission?(project_id)
      Submission.exists?(project_id: project_id, contest_id: params[:contest_id])
    end

    def redirect_unauthorized_project
      redirect_to contest_page_path(params[:contest_id]),
                  alert: "You can’t submit someone else’s project."
    end

    def redirect_duplicate_submission
      redirect_to new_submission_path(params[:contest_id]),
                  notice: "This project is already submitted in Contest ##{params[:contest_id]}"
    end

    # Feature-flag gate
    def check_contests_feature_flag
      return if Flipper.enabled?(:contests, current_user)

      redirect_to root_path, alert: "Contest feature is not available."
    end

    def concurrent_contest_exists?
      Contest.exists?(status: :live)
    end

    # Cache the total number of users for 10 minutes to avoid scanning the table
    def set_user_count
      @user_count = Rails.cache.fetch("users/total_count", expires_in: 10.minutes) { User.count }
    end

    # Strong params
    def contest_params
      params.fetch(:contest, {}).permit(:name, :title, :description, :deadline, :status)
    end

    def find_withdrawable_submission
      return Submission.find(params[:submission_id]) if current_user.admin?

      current_user.submissions.find(params[:submission_id])
    end
end
# rubocop:enable Metrics/ClassLength
