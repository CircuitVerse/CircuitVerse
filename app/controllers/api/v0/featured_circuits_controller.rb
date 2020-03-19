module Api
  module V0

    class FeaturedCircuitsController < ApplicationController

      before_action :set_project, only:[:show]
      before_action :authorize_request, except: [:index]
      before_action :set_options

      skip_before_action :verify_authenticity_token

      def index
        @projects = Project.joins(:featured_circuit)
        render :json => ProjectSerializer.new(@projects, @options).serialized_json
      end

      def show
        @project.increase_views(current_user)
        render :json => ProjectSerializer.new(@project, @options).serialized_json
      end

      private

        def set_project
          @project = Project.find(FeaturedProject.find(params[:id]).project_id)
          @author = @project.author
        end

        def set_options
          @options = {}
          @options[:include] = [:author]
        end

      end

  end
end

