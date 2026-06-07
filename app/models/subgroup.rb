# frozen_string_literal: true

class Subgroup < ApplicationRecord
  belongs_to :group
  has_many   :subgroup_members, dependent: :destroy
  has_many   :users, through: :subgroup_members

  validates :name, presence: true
  validates :name, uniqueness: { scope: :group_id }
  validates :max_size, numericality: { greater_than: 0 }, allow_nil: true

  def full?
    return false unless max_size
    subgroup_members.count >= max_size
  end
end
