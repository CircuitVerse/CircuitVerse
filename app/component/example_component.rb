# frozen_string_literal: true

class ExampleComponent < ViewComponent::Base
  def initialize(title:)
    super
    @title = title
  end

end
