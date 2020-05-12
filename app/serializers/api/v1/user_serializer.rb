# frozen_string_literal: true

class Api::V1::UserSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :email, :name, :admin,
             :country, :educational_institute,
             :subscribed, :created_at, :updated_at
end
