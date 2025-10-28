# frozen_string_literal: true

class Contest::IndexPageComponent < ViewComponent::Base
  def initialize(contests:, current_user:, notice: nil)
    super()
    @contests     = contests
    @current_user = current_user
    @notice       = notice
  end

  attr_reader :contests, :current_user, :notice
end
