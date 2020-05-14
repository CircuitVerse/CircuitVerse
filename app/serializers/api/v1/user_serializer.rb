# frozen_string_literal: true

class Api::V1::UserSerializer
  include FastJsonapi::ObjectSerializer

  attribute :email, if: Proc.new { |record, params|
    params[:has_email_access] == true || record.admin
  }

  attributes :name, :admin,
             :country, :educational_institute,
             :subscribed, :created_at, :updated_at
end
