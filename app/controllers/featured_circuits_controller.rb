# frozen_string_literal: true

class FeaturedCircuitsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_and_authorize_featured, except: [:index]

  def index
    @projects = Project.joins(:featured_circuit)
  end

  def create
    if @featured_circuit.nil? && featured_circuit_params[:featured] == "1"
      # featured_circuit doesn't exist and checkbox is marked
      FeaturedCircuit.create(project_id: featured_circuit_params[:project_id])
    end
  end

  def destroy
    # if featured_circuit exist and checkbox is unmarked
    @featured_circuit.destroy if @featured_circuit && featured_circuit_params[:featured] == "0"
  end

  private

    def set_and_authorize_featured
      authorize FeaturedCircuit, :admin?
      @featured_circuit = FeaturedCircuit.find_by(project_id: featured_circuit_params[:project_id])
    end

    def featured_circuit_params
      params.require(:featured_circuit).permit(:project_id, :featured)
    end
end
