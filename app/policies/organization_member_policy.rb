# frozen_string_literal: true

class OrganizationMemberPolicy < ApplicationPolicy
  def admin_access?
    org_admin? || user.admin?
  end

  def update?
    return false unless org_admin?
    return false if demoting_sole_admin?

    true
  end

  def destroy?
    return false if leaving_self? && sole_admin?

    org_admin? || leaving_self?
  end

  private

    def org_membership
      @org_membership ||= record.organization.organization_members.find_by(user: user)
    end

    def org_admin?
      org_membership&.role == "admin" || user.admin?
    end

    def leaving_self?
      record.user == user
    end

    def sole_admin?
      record.role == "admin" &&
        record.organization.organization_members.where(role: :admin).count == 1
    end

    def demoting_sole_admin?
      sole_admin?
    end
end