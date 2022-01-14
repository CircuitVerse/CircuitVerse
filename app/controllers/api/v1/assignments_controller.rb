# frozen_string_literal: true

class Api::V1::AssignmentsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_options, only: %i[index show create update]
  before_action :set_group, only: %i[index create]
  before_action :set_assignment, only: %i[show update destroy reopen start close]
  before_action :check_show_access, only: %i[index]
  before_action :check_access, only: %i[update destroy reopen close]
  after_action :check_reopening_status, only: [:update]

  WHITELISTED_INCLUDE_ATTRIBUTES = %i[projects grades].freeze

  # GET /api/v1/groups/:group_id/assignments
  def index
    @assignments = paginate(@group.assignments)
    @options[:links] = link_attrs(@assignments, api_v1_group_assignments_url(@group.id))
    render json: Api::V1::AssignmentSerializer.new(@assignments, @options)
  end

  # GET /api/v1/assignments/:id
  def show
    authorize @assignment, :show?
    render json: Api::V1::AssignmentSerializer.new(@assignment, @options)
  end

  # POST /api/v1/groups/:group_id/assignments
  def create
    @assignment = @group.assignments.new(assignment_create_params)
    authorize @assignment, :admin_access?
    @assignment.status = "open"
    @assignment.deadline = Time.zone.now + 1.year if @assignment.deadline.nil?
    @assignment.save!
    render json: Api::V1::AssignmentSerializer.new(@assignment, @options), status: :created
  end

  # PATCH /api/v1/assignments/:id
  def update
    @assignment.update!(assignment_update_params)
    if @assignment.update(assignment_update_params)
      render json: Api::V1::AssignmentSerializer.new(@assignment, @options), status: :accepted
    else
      invalid_resource!(@assignment.errors)
    end
  end

  # DELETE /api/v1/assignments/:id
  def destroy
    @assignment.destroy!
    render json: {}, status: :no_content
  end

  # PATCH /api/v1/assignments/:id/reopen
  def reopen
    if @assignment.status == "open"
      api_error(status: 409, errors: "Project is already opened!")
    else
      @assignment.status = "open"
      @assignment.deadline = Time.zone.now + 1.day
      @assignment.save!
      render json: { "message": "Assignment has been reopened!" }, status: :accepted
    end
  end

  # PUT /api/v1/assignments/:id/close
  def close
    authorize @assignment
    if @assignment.status == "closed"
      api_error(status: 409, errors: "Assignment is already closed!")
    else
      @assignment.status = "closed"
      @assignment.deadline = Time.zone.now
      @assignment.save!
      render json: { "message": "Assignment has been closed!" }, status: :accepted
    end
  end

  # PATCH /api/v1/assignments/:id/start
  def start
    authorize @assignment
    @project = current_user.projects.new
    @project.name = "#{current_user.name}/#{@assignment.name}"
    @project.assignment_id = @assignment.id
    @project.project_access_type = "Private"
    @project.build_project_datum
    @project.save!
    render json: {
      "message": "Voila! Project set up under name #{@project.name}"
    }, status: :created
  end

  private

    # include=projects,grades
    def include_resource
      params[:include].split(",")
                      .map { |resource| resource.strip.to_sym }
                      .select { |resource| WHITELISTED_INCLUDE_ATTRIBUTES.include?(resource) }
    end

    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def set_group
      @group = Group.find(params[:group_id])
    end

    # sets @current_user as params to be used in assignment serializer
    def set_options
      @options = {}
      @options[:include] = include_resource if params.key?(:include)
      @options[:params] = { current_user: current_user }
    end

    def check_reopening_status
      @assignment.check_reopening_status
    end

    def assignment_create_params
      params.require(:assignment).permit(
        :name, :deadline, :description, :grading_scale, :restrictions
      )
    end

    def assignment_update_params
      params.require(:assignment).permit(
        :name, :deadline, :description, :restrictions
      )
    end

    def check_show_access
      # checks if current_user has access to group contents
      authorize @group, :show_access?
    end

    def check_access
      authorize @assignment, :admin_access?
    end
end
