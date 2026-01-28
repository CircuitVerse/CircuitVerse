# frozen_string_literal: true

class Avo::Resources::IssueCircuitDatum < Avo::BaseResource
  self.title = :id
  self.includes = []
  self.model_class = ::IssueCircuitDatum

  def fields
    field :id, as: :id, link_to_resource: true
    field :data, as: :textarea
    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
  end

  def filters
    filter Avo::Filters::IssueCircuitDataId
    filter Avo::Filters::IssueCircuitDataContent
    filter Avo::Filters::IssueCircuitDataCreatedAt
    filter Avo::Filters::IssueCircuitDataUpdatedAt
  end

  def actions
    action Avo::Actions::ExportIssueCircuitData
  end
end
