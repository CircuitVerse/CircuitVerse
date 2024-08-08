# frozen_string_literal: true

class ContestWinner < ApplicationRecord
  belongs_to :submission
  belongs_to :project
  belongs_to :contest
end
