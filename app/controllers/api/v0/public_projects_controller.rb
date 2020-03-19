module Api
  module V0

    class PublicProjectsController < ApplicationController

      skip_before_action :verify_authenticity_token
      before_action :set_options

      def index
        @projects = Project.where(project_access_type: "Public")
        render :json => ProjectSerializer.new(@projects, @options).serialized_json
      end

      def show
        @project = Project.find(params[:id])
        render :json => ProjectSerializer.new(@project, @options).serialized_json
      end

      private

        def set_options
          @options = {}
          @options[:include] = [:author]
        end

    end

  end
end
