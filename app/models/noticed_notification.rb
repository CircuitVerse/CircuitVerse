# frozen_string_literal: true

class NoticedNotification < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true, optional: true
end
