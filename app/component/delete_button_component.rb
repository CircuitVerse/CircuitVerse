# frozen_string_literal: true

class DeleteButtonComponent < ViewComponent::Base
  def initialize(current_user:, profile_id:)
    super
      @current_user = current_user
      @profile_id = profile_id
  end
  
  def render?
    @current_user.present?
  end
end
