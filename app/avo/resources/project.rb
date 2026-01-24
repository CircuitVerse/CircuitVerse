# frozen_string_literal: true

class Avo::Resources::Project < Avo::BaseResource
  self.title = :name
  self.includes = %i[author assignment forked_project tags featured_circuit]
  self.search = {
    query: -> { query.text_search(params[:q]) }
  }
  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id
    field :name, as: :text, required: true, sortable: true
    field :slug, as: :text, readonly: true
    field :project_access_type, as: :select,
                                enum: {
                                  "Public" => "Public",
                                  "Private" => "Private",
                                  "Limited Access" => "Limited Access"
                                },
                                sortable: true
    field :description, as: :textarea
    field :view, as: :number, readonly: true
    field :created_at, as: :date_time, readonly: true
    field :updated_at, as: :date_time, readonly: true

    # Associations
    field :author, as: :belongs_to, searchable: true
    field :assignment, as: :belongs_to
    field :forked_project, as: :belongs_to, use_resource: "Avo::Resources::Project"

    # Reverse associations
    field :forks, as: :has_many
    field :stars, as: :has_many
    field :collaborations, as: :has_many
    field :submissions, as: :has_many

    # Tags
    field :tag_list, as: :text, help: "Comma-separated tags"

    # Image
    field :image_preview, as: :file, is_image: true
    field :circuit_preview, as: :file

    # Boolean fields
    field :project_submission, as: :boolean

    # Featured
    field :featured_circuit, as: :has_one
  end
  # rubocop:enable Metrics/MethodLength

  def filters
    filter Avo::Filters::ProjectAccessType
    filter Avo::Filters::ProjectFeatured
  end
end
