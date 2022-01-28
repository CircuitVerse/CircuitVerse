# frozen_string_literal: true

class AssignmentsController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  include SanitizeDescription

  before_action :authenticate_user!
  before_action :set_assignment, only: %i[show edit update destroy start reopen close]
  before_action :set_group
  before_action :check_access, only: %i[edit update destroy reopen close]
  before_action :sanitize_assignment_description, only: %i[show edit]
  after_action :check_reopening_status, only: [:update]
  after_action :allow_iframe_lti, only: %i[show], constraints: lambda {
    Flipper.enabled?(:lms_integration, current_user)
  }

  # GET /assignments
  # GET /assignments.json
  def index
    @assignments = Assignment.all
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
    authorize @assignment
    @assignment = AssignmentDecorator.new(@assignment)
  end

  def start
    authorize @assignment
    @project = current_user.projects.new
    @project.name = "#{current_user.name}/#{@assignment.name}"
    @project.assignment_id = @assignment.id
    @project.project_access_type = "Private"
    @project.build_project_datum
    @project.save
    redirect_to user_project_path(current_user, @project)
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
    @assignment.group_id = params[:group_id]
    @assignment.deadline = Time.zone.now + 1.week
    authorize @assignment, :admin_access?
  end

  # GET /assignments/1/edit
  def edit
    authorize @assignment
  end

  def reopen
    authorize @assignment
    @assignment.status = "open"
    @assignment.deadline = Time.zone.now + 1.day
    @assignment.save

    redirect_to edit_group_assignment_path(@group, @assignment)
  end

  # Close assignment
  def close
    authorize @assignment
    @assignment.status = "closed"
    @assignment.deadline = Time.zone.now
    @assignment.save

    redirect_to group_assignment_path(@group, @assignment)
  end

  # POST /assignments
  # POST /assignments.json
  def create
    description = params["description"]

    if Flipper.enabled?(:lms_integration, current_user) && params["lms-integration-check"]
      lti_consumer_key = SecureRandom.hex(4)
      lti_shared_secret = SecureRandom.hex(4)
    end

    params = assignment_create_params
    # params[:deadline] = params[:deadline].to_time

    @assignment = @group.assignments.new(params)
    authorize @assignment, :admin_access?

    @assignment.description = description
    @assignment.status = "open"
    @assignment.deadline = Time.zone.now + 1.year if @assignment.deadline.nil?

    if Flipper.enabled?(:lms_integration, current_user)
      @assignment.lti_consumer_key = lti_consumer_key
      @assignment.lti_shared_secret = lti_shared_secret
    end

    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @group, notice: "Assignment was successfully created." }
        format.json { render :show, status: :created, location: @assignment }
      else
        format.html { render :new }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignments/1
  # PATCH/PUT /assignments/1.json
  def update
    description = params["description"]

    if Flipper.enabled?(:lms_integration, current_user) && params["lms-integration-check"]
      lti_consumer_key = @assignment.lti_consumer_key.presence || SecureRandom.hex(4)
      lti_shared_secret = @assignment.lti_shared_secret.presence || SecureRandom.hex(4)
    end

    params = assignment_update_params
    @assignment.description = description

    if Flipper.enabled?(:lms_integration, current_user)
      @assignment.lti_consumer_key = lti_consumer_key
      @assignment.lti_shared_secret = lti_shared_secret
    end
    # params[:deadline] = params[:deadline].to_time

    respond_to do |format|
      if @assignment.update(params)
        format.html { redirect_to @group, notice: "Assignment was successfully updated." }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @assignment.destroy
    respond_to do |format|
      format.html { redirect_to @group, notice: "Assignment was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def allow_iframe_lti
    return unless session[:is_lti]

    response.headers["X-FRAME-OPTIONS"] = "ALLOW-FROM #{session[:lms_domain]}"
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def set_group
      @group = Group.find(params[:group_id])
    end

    def check_reopening_status
      @assignment.check_reopening_status
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_create_params
      params.require(:assignment).permit(:name, :deadline, :description, :grading_scale,
                                         :restrictions)
    end

    def assignment_update_params
      params.require(:assignment).permit(:name, :deadline, :description,
                                         :restrictions)
    end

    def check_access
      authorize @assignment, :admin_access?
    end

    def sanitize_assignment_description
      @assignment.description = sanitize_description(@assignment.description)
    end
end
