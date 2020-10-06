# frozen_string_literal:true

class Fcm < ApplicationRecord
  belongs_to :user

  validates :token, presence: true
  validates :user_id, uniqueness: true
end
