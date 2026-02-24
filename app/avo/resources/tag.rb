# frozen_string_literal: true

class Avo::Resources::Tag < Avo::BaseResource
  self.title = :name
  self.includes = %i[taggings projects]
  self.model_class = ::Tag

  self.search_query = lambda {
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  }

  def fields
    field :id, as: :id, link_to_record: true
    field :name, as: :text, required: true, sortable: true

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true

    field :taggings, as: :has_many
    field :projects, as: :has_many, through: :taggings
  end
end
