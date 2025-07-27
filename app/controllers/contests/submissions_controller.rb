# frozen_string_literal: true

class Contests::SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contest
  before_action :check_contests_feature_flag

  def new
    @submission = @contest.submissions.new
    @projects = current_user.projects
  end

  def create
    @submission = @contest.submissions.new(submission_params.merge(user_id: current_user.id))

    return unless validate_submission

    if @submission.save
      redirect_to contest_path(@contest), notice: t(".success")
    else
      @projects = current_user.projects
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    submission = current_user.admin? ? @contest.submissions.find(params[:id]) : current_user.submissions.find(params[:id])
    submission.destroy!
    redirect_to contest_path(@contest), notice: t(".success")
  end

  private

    def set_contest
      @contest = Contest.find(params[:contest_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to contests_path, alert: t("contest_not_found")
    end

    def check_contests_feature_flag
      redirect_to root_path, alert: t("feature_not_available") unless Flipper.enabled?(:contests, current_user)
    end

    def submission_params
      params.require(:submission).permit(:project_id)
    end

    def validate_submission
      project_id = submission_params[:project_id]
      unless project_owner?(project_id)
        redirect_to contest_path(@contest), alert: t(".unauthorized_project")
        return false
      end
      if duplicate_submission?(project_id)
        redirect_to new_contest_submission_path(@contest), notice: t(".duplicate_submission", contest_id: @contest.id)
        return false
      end
      true
    end

    def project_owner?(project_id)
      current_user.projects.exists?(id: project_id)
    end

    def duplicate_submission?(project_id)
      @contest.submissions.exists?(project_id: project_id)
    end
end
