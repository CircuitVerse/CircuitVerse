# frozen_string_literal: true

class Contests::SubmissionsController < ApplicationController
  skip_after_action :verify_authorized, only: %i[new create]

  before_action :authenticate_user!
  before_action :set_contest
  before_action :check_contests_feature_flag

  def new
    @projects = current_user.projects
    @submission = @contest.submissions.new
  end

  def create
    project_id = params[:submission][:project_id]

    @submission = @contest.submissions.new(project_id: project_id, user_id: current_user.id)

    return redirect_unauthorized_project unless policy(@submission).create?
    return redirect_duplicate_submission if duplicate_submission?(project_id)

    if @submission.save
      redirect_to contest_path(@contest), notice: t(".success")
    else
      @projects = current_user.projects
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    submission = @contest.submissions.find(params.expect(:id))
    authorize submission, :destroy?

    return redirect_to contest_path(submission.contest), alert: t(".withdraw_closed") if submission.contest.completed?

    submission.destroy!
    redirect_to contest_path(submission.contest), notice: t(".success")
  end

  private

    def set_contest
      @contest = Contest.find(params.expect(:contest_id))
    end

    def duplicate_submission?(project_id)
      @contest.submissions.exists?(project_id: project_id)
    end

    def redirect_unauthorized_project
      redirect_to contest_path(@contest), alert: t(".unauthorized_project")
    end

    def redirect_duplicate_submission
      redirect_to new_contest_submission_path(@contest), notice: t(".duplicate_submission", contest_id: @contest.id)
    end

    def check_contests_feature_flag
      return if Flipper.enabled?(:contests, current_user)

      redirect_to root_path, alert: t("feature_not_available")
    end
end
