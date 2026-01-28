# frozen_string_literal: true

class Avo::Resources::AhoyEvent < Avo::BaseResource
  self.title = :name
  self.includes = %i[visit user]
  self.model_class = ::Ahoy::Event

  def fields
    field :id, as: :id, link_to_resource: true
    field :visit, as: :belongs_to, searchable: true
    field :user, as: :belongs_to, searchable: true
    field :name, as: :text, sortable: true
    field :properties, as: :textarea
    field :time, as: :date_time, sortable: true
  end

  def filters
    filter Avo::Filters::AhoyEventName
    filter Avo::Filters::AhoyEventTime
    filter Avo::Filters::AhoyEventUser
    filter Avo::Filters::AhoyEventDateRange
  end

  def actions
    action Avo::Actions::ExportAhoyEvents
  end
end
