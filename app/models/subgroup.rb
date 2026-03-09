# frozen_string_literal: true

class Subgroup < ApplicationRecord
  belongs_to :group

  validates :name, presence: true
end
