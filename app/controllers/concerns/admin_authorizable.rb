# frozen_string_literal: true

module AdminAuthorizable
  extend ActiveSupport::Concern

  private

    def authorize_admin
      authorize admin_authorization_class, :admin?
    end

    def admin_authorization_class
      controller_name.classify.constantize
    end
end
