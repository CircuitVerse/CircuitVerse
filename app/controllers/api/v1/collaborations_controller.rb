# frozen_string_literal: true

class Api::V1::CollaborationsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_project, only: %i[index create]
  before_action :check_author_access, only: %i[create]
  before_action :set_collaboration, only: %i[destroy]

  # /api/v1/projects/:project_id/collaborations
  def index
    @collaborations = paginate(@project.collaborations)
    @options = { links: link_attrs(@collaborations, api_v1_project_collaborations_url) }
    render json: Api::V1::CollaborationSerializer.new(@collaborations, @options)
  end

  # POST /api/v1/projects/:project_id/collaborations
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

    render json: { added: @added_mails, invalid: @invalid_mails }
  end

  # DELETE /api/v1/collaborations/:id
  def destroy
    authorize @collaboration.project, :author_access?
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

    def set_collaboration
      @collaboration = Collaboration.find(params[:id])
    end

    def collaboration_params
      params.require(:collaboration).permit(:user_id, :project_id, :emails)
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
