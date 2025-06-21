# frozen_string_literal: true

class EditorPickComponent < ViewComponent::Base
  def initialize(featured_circuits:, current_user:)
    @featured_circuits = featured_circuits
    @current_user = current_user
  end
end




