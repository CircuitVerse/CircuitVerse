# frozen_string_literal: true

class Avo::Resources::Project < Avo::BaseResource
  self.title = :name
  self.includes = %i[author assignment forked_project tags featured_circuit]
  self.model_class = ::Project
  self.search = {
    query: -> { query.text_search(params[:q]) }
  }

  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_record: true
    field :name, as: :text, required: true, sortable: true
    field :author, as: :belongs_to, searchable: true
    field :forked_project, as: :belongs_to, use_resource: "Avo::Resources::Project", searchable: true
    field :project_access_type, as: :select,
                                enum: {
                                  "Public" => "Public",
                                  "Private" => "Private",
                                  "Limited Access" => "Limited Access"
                                },
                                sortable: true
    field :assignment, as: :belongs_to, searchable: true
    field :project_submission, as: :boolean

    field :image_preview, as: :external_image, hide_on: %i[edit new] do
      record.image_preview.url if record.image_preview.present?
    end
    field :description, as: :textarea
    field :view, as: :number, sortable: true
    field :slug, as: :text, readonly: true, help: "Auto-generated from name"
    field :lis_result_sourced_id, as: :text
    field :version, as: :text
    field :stars_count, as: :number, readonly: true, sortable: true

    field :forks, as: :has_many
    field :stars, as: :has_many
    field :user_ratings, as: :has_many, through: :stars
    field :collaborations, as: :has_many
    field :collaborators, as: :has_many, through: :collaborations
    field :taggings, as: :has_many
    field :tags, as: :has_many
    field :tag_list, as: :tags
    field :circuit_preview, as: :file

    field :featured_circuit, as: :has_one
    field :grade, as: :has_one
    field :project_datum, as: :has_one
    field :contest_winner, as: :has_one
    field :submissions, as: :has_many
    field :commontator_thread, as: :has_one

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
  end
  # rubocop:enable Metrics/MethodLength
end
