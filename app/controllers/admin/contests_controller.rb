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

    # The Model now handles the default name, so we only pass simple parameters.
    # We use contest_params to allow passing a custom name from the host modal.
    @contest = Contest.new(contest_params.reverse_merge(deadline: 1.month.from_now, status: :live))

    if @contest.save
      ContestScheduler.call(@contest)
      redirect_to contest_path(@contest), notice: t(".success")
    else
      @contests = Contest.order(id: :desc).paginate(page: params[:page]).limit(Contest.per_page)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @contest = Contest.find(params[:id])

    if params[:contest][:status] == "completed"
      handle_contest_completion
    elsif params[:contest].key?(:name) && params[:contest][:deadline].blank?
      handle_name_update
    elsif params[:contest][:deadline].present?
      handle_deadline_update
    else
      redirect_to admin_contests_path, alert: t(".invalid_update_request")
    end
  end

  private

    def authorize_admin
      authorize Contest, :admin?
    end

    def concurrent_contest_exists?
      Contest.exists?(status: :live)
    end

    # Used for Contest creation (Host new contest modal)
    def contest_params
      params.fetch(:contest, {}).permit(:name, :title, :description, :deadline, :status)
    end

    # Allows only the name field for the Name Update Modal
    def name_params
      params.expect(contest: [:name])
    end

    # Allows only the status and a forced deadline of Time.zone.now for closure
    def status_params
      params.expect(contest: [:status]).merge(deadline: Time.zone.now)
    end

    # Allows only the deadline field
    def deadline_params
      params.expect(contest: [:deadline])
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

    def handle_contest_completion
      ShortlistContestWinner.new(@contest.id).call
      if @contest.update(status_params.except(:deadline).merge(deadline: Time.zone.now))
        redirect_to contest_path(@contest), notice: t(".contest_closed")
      else
        render :index, status: :unprocessable_entity
      end
    end

    def handle_name_update
      if @contest.update(name_params)
        redirect_to admin_contests_path, notice: t(".name_updated")
      else
        redirect_to admin_contests_path,
                    alert: t(".name_update_failed", errors: @contest.errors.full_messages.join(", "))
      end
    end

    def handle_deadline_update
      parsed_deadline = parse_deadline_or_redirect(params[:contest][:deadline])
      return if performed?

      return redirect_to(admin_contests_path, alert: t(".deadline_in_future")) if parsed_deadline <= Time.zone.now

      if @contest.update(deadline_params.merge(deadline: parsed_deadline))
        ContestScheduler.call(@contest)
        redirect_to admin_contests_path, notice: t(".deadline_updated")
      else
        redirect_to admin_contests_path,
                    alert: t(".deadline_update_failed", errors: @contest.errors.full_messages.join(", "))
      end
    end
end
