# frozen_string_literal: true

class Api::V1::UserSerializer
  include FastJsonapi::ObjectSerializer

  # only name is serialized if all users/collaborators are fetched
  attribute :name, :locale

  # only serialized if user fetches own details
  attributes :email, :subscribed, :created_at, :updated_at, :profile_picture,
             if: proc { |record, params|
               params[:has_details_access] == true || record.admin
             }

  attributes :admin, :country, :educational_institute,
             if: proc { |record, params|
               params[:only_name] != true || record.admin
             }

  attribute :profile_picture do |profile_picture|
    if profile_picture.profile_picture.attached?
      Rails.application.routes.url_helpers.rails_blob_url(profile_picture.profile_picture, only_path: true)
    end
  end
end
