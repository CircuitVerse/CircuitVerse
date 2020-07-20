# frozen_string_literal: true

class Mentorship < ApplicationRecord
  belongs_to :user
  belongs_to :group
end
