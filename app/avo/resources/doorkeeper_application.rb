# frozen_string_literal: true

class Avo::Resources::DoorkeeperApplication < Avo::BaseResource
  self.title = :name
  self.model_class = "Doorkeeper::Application"

  def self.includes
    []
  end

  def fields
    field :id, as: :id
    field :name, as: :text, required: true
    field :uid, as: :text, readonly: true
    field :secret, as: :text, readonly: true
    field :redirect_uri, as: :text, required: true
    field :scopes, as: :text
    field :confidential, as: :boolean
  end
end
