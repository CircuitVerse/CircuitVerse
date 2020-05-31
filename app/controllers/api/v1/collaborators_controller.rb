# frozen_string_literal: true

class Api::V1::CollaboratorsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_project
  before_action :check_author_access, only: %i[create destroy]
  before_action :set_collaborator, only: %i[destroy]

  # /api/v1/projects/:project_id/collaborators
  def index
    @collaborators = paginate(@project.collaborators)
    # options for serializing collaborators
    @options = {
      params: { only_name: true },
      links: link_attrs(@collaborators, api_v1_project_collaborators_url)
    }
    render json: Api::V1::UserSerializer.new(@collaborators, @options)
  end

  # POST /api/v1/projects/:project_id/collaborators
  def create
    parse_mails_except_current_user(params[:emails])
    newly_added = @valid_mails - @existing_mails

    @added_mails = []

    newly_added.each do |email|
      user = User.find_by(email: email)
      if user.present?
        @added_mails.push(email)
        Collaboration.where(project_id: @project.id, user_id: user.id).first_or_create
      end
    end

    render json: { added: @added_mails, existing: @existing_mails, invalid: @invalid_mails }
  end

  # DELETE /api/v1//projects/:project_id/collaborators/:id
  # :id is essentially the user_id for the user to be removed from project
  def destroy
    @collaboration = Collaboration.find_by(user: @collaborator, project: @project)
    @collaboration.destroy!
    render json: {}, status: :no_content
  end

  private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def check_author_access
      authorize @project, :author_access?
    end

    def set_collaborator
      @collaborator = @project.collaborators.find(params[:id])
    end

    def collaborator_params
      params.require(:collaborator).permit(:project_id, :emails)
    end

    def parse_mails_except_current_user(mails)
      @valid_mails = []
      @invalid_mails = []

      mails.split(",").each do |email|
        email = email.strip
        if email.present? && email != @current_user.email \
          && Devise.email_regexp.match?(email)
          @valid_mails.push(email)
        else
          @invalid_mails.push(email)
        end
      end

      @existing_mails = User.where(
        id: @project.collaborations.pluck(:user_id)
      ).pluck(:email)
    end
end
