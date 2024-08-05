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
    @circuit ? @circuit.name : "Full Adder"
  end

  def circuit_url
    if @circuit
      helpers.user_project_url(@circuit.author, @circuit)
    else
      helpers.user_project_url(User.find_by(name: "user1"), Project.find_by(name: "Full Adder"))
    end
  end
end
