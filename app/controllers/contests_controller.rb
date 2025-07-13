# frozen_string_literal: true

class ContestsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :check_contests_feature_flag
  before_action :set_user_count, only: :show

  def index
    @contests = Contest.order(id: :desc).paginate(page: params[:page]).limit(Contest.per_page)
    respond_to do |format|
      format.html
      format.json { render json: @contests }
      format.js
    end
  end

  def show
    @contest = Contest.find(params[:id])
    @user_submission = @contest.submissions.where(user_id: current_user&.id)
    @submissions = @contest.submissions.where.not(user_id: current_user&.id).paginate(page: params[:page]).limit(6)

    return unless @contest.completed? && Submission.exists?(contest_id: @contest.id)

    contest_winner = ContestWinner.find_by(contest_id: @contest.id)
    @winner = contest_winner.submission if contest_winner.present?
  end

  private

    def check_contests_feature_flag
      return if Flipper.enabled?(:contests, current_user)

      redirect_to root_path, alert: t("feature_not_available")
    end

    def set_user_count
      @user_count = Rails.cache.fetch("users/total_count", expires_in: 10.minutes) { User.count }
    end
end
