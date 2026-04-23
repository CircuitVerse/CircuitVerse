# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include Noticed::HasNotifications

  before_validation :sanitize_utf8_attributes

  private

  def sanitize_utf8_attributes
    attributes.each do |key, value|
      next unless value.is_a?(String)

      self[key] = value.scrub("")
    end
  end
end
