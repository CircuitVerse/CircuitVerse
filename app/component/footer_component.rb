# frozen_string_literal: true

class FooterComponent < ViewComponent::Base
  def initialize(current_user:)
    super()
    @current_user = current_user
  end

  def current_year
    Time.current.year
  end
end
