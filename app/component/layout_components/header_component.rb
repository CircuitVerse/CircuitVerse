# frozen_string_literal: true

module LayoutComponents
  class HeaderComponent < ViewComponent::Base
    def initialize(current_user: nil)
      super
      @current_user = current_user
    end

    private

      attr_reader :current_user

      def user_signed_in?
        current_user.present?
      end
  end
end
