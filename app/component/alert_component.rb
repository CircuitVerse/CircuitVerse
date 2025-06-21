# frozen_string_literal: true

class AlertComponent < ViewComponent::Base
    def initialize(message:)
      @message = message
    end
  end