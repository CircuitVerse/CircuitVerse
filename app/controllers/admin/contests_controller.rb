# frozen_string_literal: true

class Admin::ContestsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_contests_feature_flag
  before_action :authorize_admin

  def index
    @contests = Contest.order(id: :desc).paginate(page: params[:page]).limit(Contest.per_page)
  end

  def create
    if concurrent_contest_exists?
      redirect_to admin_contests_path, notice: t(".concurrent_contests")
      return
    end

    @contest = Contest.new(contest_params.reverse_merge(deadline: 1.month.from_now, status: :live))

    if @contest.save
      ContestScheduler.call(@contest)
      redirect_to contest_path(@contest), notice: t(".success")
    else
      @contests = Contest.order(id: :desc).paginate(page: params[:page]).limit(Contest.per_page)
      render :index, status: :unprocessable_content
    end
  end

  # rubocop:disable Metrics/MethodLength
  def update
    @contest = Contest.find(params[:id])
    if params[:contest][:status] == "completed"
      ShortlistContestWinner.new(@contest.id).call
      if @contest.update(deadline: Time.zone.now, status: :completed)
        redirect_to contest_path(@contest), notice: t(".contest_closed")
      else
        render :index, status: :unprocessable_content
      end
    else
      parsed_deadline = parse_deadline_or_redirect(params[:contest][:deadline])
      return if performed?

      return redirect_to(admin_contests_path, alert: t(".deadline_in_future")) if parsed_deadline <= Time.zone.now

      if @contest.update(deadline: parsed_deadline)
        ContestScheduler.call(@contest)
        redirect_to contest_path(@contest), notice: t(".deadline_updated")
      else
        redirect_to admin_contests_path,
                    alert: t(".deadline_update_failed", errors: @contest.errors.full_messages.join(", "))
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

    def authorize_admin
      authorize Contest, :admin?
    end

    def concurrent_contest_exists?
      Contest.exists?(status: :live)
    end

    def contest_params
      params.expect(contest: %i[name title description deadline status])
    end

    def parse_deadline_or_redirect(str)
      parsed = Time.zone.parse(str)
      redirect_to(admin_contests_path, alert: t(".invalid_deadline")) and return if parsed.nil?

      parsed
    end

    def check_contests_feature_flag
      return if Flipper.enabled?(:contests, current_user)

      redirect_to root_path, alert: t("feature_not_available")
    end
end
