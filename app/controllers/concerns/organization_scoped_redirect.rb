# frozen_string_literal: true

module OrganizationScopedRedirect
  extend ActiveSupport::Concern

  private

    def group_redirect_path(group)
      if group.organization && Flipper.enabled?(:organizations, current_user)
        return organization_group_path(group.organization, group)
      end

      group_path(group)
    end
end
