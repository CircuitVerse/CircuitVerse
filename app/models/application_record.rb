# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  self.abstract_class = true
  include Noticed::HasNotifications
end
