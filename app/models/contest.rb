# frozen_string_literal: true

class Contest < ApplicationRecord
    has_many :submissions, dependent: :destroy
end