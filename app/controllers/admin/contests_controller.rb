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

  # rubocop:disable Metrics/MethodLength
  def update
    @contest = Contest.find(params[:id])

    # 1) Logic to CLOSE the contest (status update)
    if params[:contest][:status] == "completed"
      ShortlistContestWinner.new(@contest.id).call
      if @contest.update(status_params) # status_params includes status: :completed and sets deadline: Time.zone.now
        redirect_to contest_path(@contest), notice: t(".contest_closed")
      else
        render :index, status: :unprocessable_entity
      end
      
    # 2) Logic to UPDATE NAME (Requires only :name)
    elsif params[:contest].key?(:name) && params[:contest][:deadline].blank?
      if @contest.update(name_params) 
        redirect_to admin_contests_path, notice: t(".name_updated") # Redirect to index for list updates
      else
        redirect_to admin_contests_path,
        alert: t(".name_update_failed", errors: @contest.errors.full_messages.join(", "))
      end

    # 3) Logic to UPDATE DEADLINE (Requires only :deadline)
    elsif params[:contest][:deadline].present?
      parsed_deadline = parse_deadline_or_redirect(params[:contest][:deadline])
      return if performed?

      return redirect_to(admin_contests_path, alert: t(".deadline_in_future")) if parsed_deadline <= Time.zone.now

      # Use deadline_params and merge the parsed time object
      if @contest.update(deadline_params.merge(deadline: parsed_deadline))
        ContestScheduler.call(@contest)
        redirect_to admin_contests_path, notice: t(".deadline_updated") # Redirect to index for list updates
      else
        redirect_to admin_contests_path,
        alert: t(".deadline_update_failed", errors: @contest.errors.full_messages.join(", "))
      end

    # 4) Handle invalid submission
    else
      redirect_to admin_contests_path, alert: t(".invalid_update_request")
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

    # Used for Contest creation (Host new contest modal)
    def contest_params
      params.fetch(:contest, {}).permit(:name, :title, :description, :deadline, :status)
    end

    # Allows only the name field for the Name Update Modal
    def name_params
      params.require(:contest).permit(:name)
    end

    # Allows only the status and a forced deadline of Time.zone.now for closure
    def status_params
      params.require(:contest).permit(:status).merge(deadline: Time.zone.now)
    end

    # Allows only the deadline field
    def deadline_params
      params.require(:contest).permit(:deadline)
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