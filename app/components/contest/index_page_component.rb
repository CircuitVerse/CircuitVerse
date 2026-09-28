# frozen_string_literal: true

class Contest::IndexPageComponent < ViewComponent::Base
  def initialize(contests:, current_user:, pagy:, notice: nil)
    super()
    @contests     = contests
    @current_user = current_user
    @pagy         = pagy
    @notice       = notice
  end

  attr_reader :contests, :current_user, :pagy, :notice
end
