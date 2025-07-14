# frozen_string_literal: true

module HomepageComponents
  class HomeButtonComponent < ViewComponent::Base
    def initialize(path:, text_key:)
      super
      @path = path
      @text_key = text_key
    end
  end
end
