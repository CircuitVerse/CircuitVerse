module Api
  module V0

    class FeaturedCircuitsController < ApplicationController

      before_action :set_project, only:[:show]
      before_action :authorize_request, except: [:index]

      def index
        @projects = Project.joins(:featured_circuit)
        render :json => @projects
      end

      def show
        @project.increase_views(current_user)
        render :json => @project
      end

      private

        def set_project
          @project = Project.find(FeaturedProject.find(params[:id]).project_id)
          @author = @project.author
        end

      end

  end
end

