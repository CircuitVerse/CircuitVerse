# frozen_string_literal: true

class About::TeamSectionCardComponent < ViewComponent::Base
  def initialize(member:, underline: false)
    super()
    @member = member
    @underline = underline
  end

  private

    attr_reader :member, :underline
end
