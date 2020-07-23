# frozen_string_literal: true

class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_assignment, only: %i[show edit update destroy start reopen]
  before_action :set_group
  before_action :check_access, only: %i[edit update destroy reopen]
  after_action :check_reopening_status, only: [:update]

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
    @project.name = current_user.name + "/" + @assignment.name
    @project.assignment_id = @assignment.id
    @project.project_access_type = "Private"
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

  def check_reopening_status
    @assignment.projects.each do |proj|
      next unless proj.project_submission == true

      old_project = Project.find_by(id: proj.forked_project_id)
      if old_project.nil?
        proj.project_submission = false
        proj.save
      else
        old_project.assignment_id = proj.assignment_id
        old_project.save
        proj.destroy
      end
    end
  end

  # POST /assignments
  # POST /assignments.json
  def create
    description = params["description"]
    params = assignment_create_params
    # params[:deadline] = params[:deadline].to_time

    @assignment = @group.assignments.new(params)
    authorize @assignment, :admin_access?

    puts(params)
    @assignment.description = description
    @assignment.status = "open"
    @assignment.deadline = Time.zone.now + 1.year if @assignment.deadline.nil?

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
    params = assignment_update_params
    @assignment.description = description
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
      format.html { redirect_to @group, notice: "Assignment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    def set_group
      @group = Group.find(params[:group_id])
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
end
