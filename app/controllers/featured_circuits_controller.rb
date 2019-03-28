# frozen_string_literal: true

class FeaturedCircuitsController < ApplicationController
  before_action :authenticate_user!, only: [:feature]

  def feature
    authorize FeaturedCircuit, :admin?
    featured_circuit = FeaturedCircuit.find_by(project_id: featured_circuit_params[:project_id])

    if featured_circuit
      # if featured_circuit exist and checkbox is unmarked
      featured_circuit.destroy if featured_circuit_params[:featured] == "0"
    elsif featured_circuit_params[:featured] == "1"
      # featured_circuit doesn't exist and checkbox is marked
      FeaturedCircuit.create(project_id: featured_circuit_params[:project_id])
    end
  end

  private

    def featured_circuit_params
      params.require(:featured_circuit).permit(:project_id, :featured)
    end
end
