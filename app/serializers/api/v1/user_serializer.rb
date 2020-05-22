# frozen_string_literal: true

class Api::V1::UserSerializer
  include FastJsonapi::ObjectSerializer

  # only name is serialized if all users are fetched
  attribute :name

  # only serialized if user fetches own details
  attributes :email, :subscribed, :created_at, :updated_at,
             if: proc { |record, params|
               params[:has_details_access] == true || record.admin
             }

  attributes :admin, :country, :educational_institute,
             if: proc { |record, params|
               params[:are_all_users_fetched] != true || record.admin
             }
end
