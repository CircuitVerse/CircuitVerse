# frozen_string_literal: true

class Api::V1::NotificationSerializer
  include FastJsonapi::ObjectSerializer

  attributes :recipient_type, :recipient_id, :type,
            :read_at, :created_at, :updated_at

  attributes :unread, &:unread?
end
