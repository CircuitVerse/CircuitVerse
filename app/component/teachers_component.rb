# frozen_string_literal: true

class TeachersComponent < ViewComponent::Base
  def initialize(feature:)
    @feature = feature
    super
  end

  private

    attr_reader :feature

    def feature_image
      feature[:image_right] ? "order-md-1" : ""
    end

    def feature_content
      feature[:image_right] ? "order-md-2" : ""
    end

    def teacher_feature_section
      feature[:bg_light] ? "feature-section bg-light" : "feature-section"
    end
end
