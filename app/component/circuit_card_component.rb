# frozen_string_literal: true

class CircuitCardComponent < ViewComponent::Base
  with_collection_parameter :circuit
  
  def initialize(circuit:, current_user:)
    super
    @circuit = circuit
    @current_user = current_user
  end
  
  def image_path
    helpers.project_image_preview(@circuit, @current_user)
  end
  
  def circuit_name
    @circuit.name
  end
  
  def circuit_url
    helpers.user_project_url(@circuit.author, @circuit)
  end
end
  