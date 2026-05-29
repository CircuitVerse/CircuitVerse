# frozen_string_literal: true

class OrganizationMember < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :role, { admin: 0, mentor: 1, member: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :organization_id }
end
