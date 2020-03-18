module Api
  module V0
    class ProjectsController < ApplicationController
      include ActionView::Helpers::SanitizeHelper

      before_action :set_project, only: [:show, :update, :destroy]
      before_action :authorize_request, only: [:index, :show, :update, :destroy]
      before_action :check_access , only: [:update, :destroy]
      before_action :check_delete_access , only: [:destroy]
      before_action :check_view_access , only: [:show]
      before_action :sanitize_name, only: [:update]

      skip_before_action :verify_authenticity_token

      def index
        @projects = Project.where(author_id: @current_user.id)
        render :json => @projects
      end

      def show
        @project.increase_views(@current_user)
        render :json => @project
      end

      def update
        @project.update(project_params)
        if @project.update(project_params)
          render :json => @project, status: :ok
        else
          render :json => @project.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @project.destroy
        render :json => {}, status: :no_content
      end

      private

        def set_project
          @project = Project.find(params[:id])
          @author = @project.author
        end

        def check_access
          authorize @project, :edit_access?
        end

        def check_delete_access
          authorize @project, :author_access?
        end

        def check_view_access
          authorize @project, :view_access?
        end

        def project_params
          params.require(:project).permit(:name, :project_access_type, :description, :tag_list, :tags)
        end

        def sanitize_name
          params[:project][:name] = sanitize(project_params[:name])
        end

    end

  end
end
