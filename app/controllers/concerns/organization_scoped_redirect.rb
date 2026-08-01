# frozen_string_literal: true

module OrganizationScopedRedirect
  extend ActiveSupport::Concern

  included do
    helper_method :organization_scoped_group?
  end

  def organization_scoped_group?(group)
    group.organization.present? && Flipper.enabled?(:organizations, current_user)
  end

  private

    def group_redirect_path(group)
      return organization_group_path(group.organization, group) if organization_scoped_group?(group)

      group_path(group)
    end

    def group_parent_redirect_path(organization)
      return overview_organization_path(organization) if organization && Flipper.enabled?(:organizations, current_user)

      user_groups_path(current_user)
    end
end
