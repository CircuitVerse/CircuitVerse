# frozen_string_literal: true

class CollaborationsController < ApplicationController
  before_action :set_collaboration, only: %i[update destroy]

  def self.policy_class
    ProjectPolicy
  end

  # POST /collaborations
  # POST /collaborations.json
  def create
    @project = Project.find(collaboration_params[:project_id])

    # if(not @project.assignment_id.nil?)
    #   render plain: "Assignments cannot have collaborators. Please contact admin." and return
    # end
    authorize @project, :author_access?

    already_present = User.where(id: @project.collaborations.pluck(:user_id)).pluck(:email)
    collaboration_emails = collaboration_params[:emails].grep(Devise.email_regexp)

    newly_added = collaboration_emails - already_present

    newly_added.each do |email|
      email = email.strip
      user = User.find_by(email: email)
      if user.nil?
        # PendingInvitation.where(group_id:@group.id,email:email).first_or_create
      else
        Collaboration.where(project_id: @project.id, user_id: user.id).first_or_create
      end
    end

    notice = Utils.mail_notice(collaboration_params[:emails], collaboration_emails, newly_added)

    notice = "You can't invite yourself. #{notice}" if collaboration_params[:emails].include?(current_user.email)

    respond_to do |format|
      format.html { redirect_to user_project_path(@project.author_id, @project.id), notice: notice }
    end
  end

  # PATCH/PUT /collaborations/1
  # PATCH/PUT /collaborations/1.json
  def update
    authorize @collaboration.project, :author_access?

    respond_to do |format|
      if @collaboration.update(collaboration_params)
        format.html do
          redirect_to @collaboration, notice: "Collaboration was successfully updated."
        end
        format.json { render :show, status: :ok, location: @collaboration }
      else
        format.html { render :edit }
        format.json { render json: @collaboration.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /collaborations/1
  # DELETE /collaborations/1.json
  def destroy
    authorize @collaboration.project, :author_access?

    @collaboration.destroy
    respond_to do |format|
      format.html do
        redirect_to user_project_path(@collaboration.project.author_id, @collaboration.project_id),
                    notice: "Collaboration was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_collaboration
      @collaboration = Collaboration.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collaboration_params
      params.expect(collaboration: [:user_id, :project_id, { emails: [] }])
    end
end
