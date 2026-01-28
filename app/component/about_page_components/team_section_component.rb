# frozen_string_literal: true

class AboutPageComponents::TeamSectionComponent < ViewComponent::Base
  def initialize(title:, description:, members:, section_id: nil)
    super
    @title = title
    @description = description
    @members = members
    @section_id = section_id
  end

  private

    attr_reader :title, :description, :members, :section_id
end
