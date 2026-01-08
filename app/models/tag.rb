# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings
  has_many :projects, through: :taggings

  before_validation :sanitize_name

  validates :name, presence: true
  validates :name, length: { minimum: 1 }
  validates :name, uniqueness: { case_sensitive: false }

  private

    def sanitize_name
      return unless name.present?

      # Remove invalid UTF-8 sequences and clean up the string
      self.name = name.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
                      .strip
                      .gsub(/\u0000/, "") # Remove null bytes
    end
end
