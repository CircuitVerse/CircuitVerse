# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  def show_access?
    return true unless record.private

    member? || user.admin?
  end

  def admin_access?
    org_admin? || user.admin?
  end

  def leave?
    return false unless member?
    return false if org_admin? && sole_admin?

    true
  end

  private

    def membership
      @membership ||= record.organization_members.find_by(user: user)
    end

    def member?
      membership.present?
    end

    def org_admin?
      membership&.role == "admin"
    end

    def sole_admin?
      record.organization_members.where(role: :admin).count == 1
    end
end