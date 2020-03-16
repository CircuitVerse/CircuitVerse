module Api
  module V0

    class ProjectsController < ApplicationController

      def index
        @projects = Project.where(project_access_type: "Public")
        render :json => @projects, :include => {:author => {:only => [:name, :email]}}
      end

      def show
        @project = Project.find(params[:id])
        render :json => @project, :include => {:author => {:only => [:name, :email]}}
      end

    end

  end
end
