class Category < ApplicationRecord
  has_many :questions, dependent: :destroy
end
