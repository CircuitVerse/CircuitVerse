# frozen_string_literal: true

class Avo::Resources::CustomMail < Avo::BaseResource
  self.title = :subject
  self.includes = %i[sender]
  self.model_class = ::CustomMail
  self.search = {
    query: lambda {
      query.ransack(
        subject_cont: params[:q],
        body_cont: params[:q],
        m: "or"
      ).result(distinct: false)
    }
  }

  def fields
    field :id, as: :id, link_to_resource: true
    field :subject, as: :text, required: true
    field :body, as: :textarea, required: true
    field :sender, as: :belongs_to, searchable: true

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true
  end
end
