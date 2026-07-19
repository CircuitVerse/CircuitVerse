# frozen_string_literal: true

class ValidateDoorkeeperForeignKeys < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :oauth_access_grants, :oauth_applications
    validate_foreign_key :oauth_access_tokens, :oauth_applications
  end
end
