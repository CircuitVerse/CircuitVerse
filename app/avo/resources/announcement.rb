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
    field :id, as: :id, link_to_record: true
    field :body, as: :textarea
    field :link, as: :text
    field :start_date, as: :date_time
    field :end_date, as: :date_time

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
  end
end
