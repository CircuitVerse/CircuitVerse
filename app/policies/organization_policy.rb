# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  def show_access?
    return true unless record.private

    member? || user&.admin?
  end

  def admin_access?
    org_admin? || user&.admin?
  end

  def leave?
    return false unless member?
    return false if org_admin? && sole_admin?
    return false if record.groups.exists?(primary_mentor_id: user&.id)

    true
  end

  def create_group?
    org_admin? || org_mentor? || user&.admin?
  end

  private

    def membership
      return @membership if defined?(@membership)

      @membership = record.organization_members.find_by(user: user)
    end

    def member?
      membership.present?
    end

    def org_admin?
      membership&.role == "admin"
    end

    def org_mentor?
      membership&.role == "mentor"
    end

    def sole_admin?
      record.organization_members.where(role: :admin).one?
    end
end
