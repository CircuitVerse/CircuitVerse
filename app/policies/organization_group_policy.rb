# frozen_string_literal: true

class OrganizationGroupPolicy < ApplicationPolicy
  def manage?
    org_admin? || assigned_mentor? || user.admin?
  end

  private

    def org_membership
      return @org_membership if defined?(@org_membership)

      @org_membership = record.organization&.organization_members&.find_by(user: user)
    end

    def org_admin?
      org_membership&.role == "admin"
    end

    def assigned_mentor?
      org_membership&.role == "mentor" &&
        (record.primary_mentor_id == user.id ||
         record.group_members.exists?(user_id: user.id, mentor: true))
    end
end
