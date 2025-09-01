# frozen_string_literal: true

class Api::V1::CollaboratorsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_project
  before_action :check_author_access, except: %i[index]
  before_action :check_view_access, only: %i[index]
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
    mails_handler = MailsHandler.new(params[:emails], @project, current_user)
    # parse mails as valid or invalid
    mails_handler.parse

    render json: {
      added: mails_handler.added_mails,
      existing: mails_handler.existing_mails,
      invalid: mails_handler.invalid_mails
    }
  end

  # DELETE /api/v1//projects/:project_id/collaborators/:id
  # :id is essentially the user_id for the user to be removed from project
  def destroy
    @collaboration = Collaboration.find_by(user: @collaborator, project: @project)
    @collaboration.destroy!
    head :no_content
  end

  private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def check_author_access
      authorize @project, :author_access?
    end

    def check_view_access
      authorize @project, :check_view_access?
    end

    def set_collaborator
      @collaborator = @project.collaborators.find(params[:id])
    end

    def collaborator_params
      params.expect(collaborator: %i[project_id emails])
    end
end
