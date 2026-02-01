# frozen_string_literal: true

class Avo::Resources::Announcement < Avo::BaseResource
  self.title = :body
  self.includes = []
  self.model_class = ::Announcement
  self.search = {
    query: lambda {
      query.ransack(
        body_cont: params[:q],
        m: "or"
      ).result(distinct: false)
    }
  }

  def fields
    field :id, as: :id, link_to_resource: true
    field :body, as: :textarea, required: true
    field :link, as: :text

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true
  end
end
