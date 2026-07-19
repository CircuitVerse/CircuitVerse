# frozen_string_literal: true

class ValidateDoorkeeperOpenidConnectForeignKeys < ActiveRecord::Migration[8.1]
  def change
    validate_foreign_key :oauth_openid_requests, :oauth_access_grants
  end
end
