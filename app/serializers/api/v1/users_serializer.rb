# frozen_string_literal: true

class Api::V1::UsersSerializer
  include FastJsonapi::ObjectSerializer

  attribute :name
end
