# frozen_string_literal: true

module OrganizationScopedRedirect
  extend ActiveSupport::Concern

  included do
    helper_method :organization_scoped_group?,
                  :group_assignment_redirect_path,
                  :edit_group_assignment_redirect_path,
                  :new_group_assignment_redirect_path,
                  :reopen_group_assignment_redirect_path,
                  :close_group_assignment_redirect_path,
                  :start_group_assignment_redirect_path
  end

  def organization_scoped_group?(group)
    group.organization.present? && Flipper.enabled?(:organizations, current_user)
  end

  def group_assignment_redirect_path(group, assignment)
    if organization_scoped_group?(group)
      organization_group_assignment_path(group.organization, group, assignment)
    else
      group_assignment_path(group, assignment)
    end
  end

  def edit_group_assignment_redirect_path(group, assignment)
    if organization_scoped_group?(group)
      edit_organization_group_assignment_path(group.organization, group, assignment)
    else
      edit_group_assignment_path(group, assignment)
    end
  end

  def new_group_assignment_redirect_path(group)
    if organization_scoped_group?(group)
      new_organization_group_assignment_path(group.organization, group)
    else
      new_group_assignment_path(group)
    end
  end

  def reopen_group_assignment_redirect_path(group, assignment)
    if organization_scoped_group?(group)
      reopen_organization_group_assignment_path(group.organization, group, assignment)
    else
      reopen_group_assignment_path(group, assignment)
    end
  end

  def close_group_assignment_redirect_path(group, assignment)
    if organization_scoped_group?(group)
      close_organization_group_assignment_path(group.organization, group, assignment)
    else
      close_group_assignment_path(group, assignment)
    end
  end

  def start_group_assignment_redirect_path(group, assignment)
    if organization_scoped_group?(group)
      start_organization_group_assignment_path(group.organization, group, assignment)
    else
      assignment_start_path(group, assignment)
    end
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
