# frozen_string_literal: true
class Organization < ApplicationRecord
    has_many :groups, dependent: :nullify
    validates :name, presence: true
    validates :slug, presence: true, uniqueness: true
end
