# frozen_string_literal: true

class CircuitElementsController < ApplicationController
  before_action :authenticate_user!

  def index
    @circuit_elements = CircuitElement.joins(:assignments)
    .where(assignments: { id: params[:assignment_id] })
  end
end
