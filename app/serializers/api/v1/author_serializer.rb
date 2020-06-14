# frozen_string_literal: true

class Api::V1::AuthorSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :email
end
