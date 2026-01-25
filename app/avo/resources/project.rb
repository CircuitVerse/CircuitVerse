# frozen_string_literal: true

class Avo::Resources::Project < Avo::BaseResource
  self.title = :name
  self.includes = %i[author assignment forked_project tags featured_circuit]
  self.model_class = ::Project
  self.search = {
    query: -> { query.text_search(params[:q]) }
  }

  def fields
    basic_fields
    metadata_fields
    relationship_fields
    file_fields
  end

  private

    def basic_fields
      field :id, as: :id, link_to_resource: true
      field :name, as: :text, required: true, sortable: true, link_to_resource: true
      field :slug, as: :text, readonly: true
      field :description, as: :textarea

      field :project_access_type, as: :select,
                                  enum: {
                                    "Public" => "Public",
                                    "Private" => "Private",
                                    "Limited Access" => "Limited Access"
                                  },
                                  sortable: true
    end

    def metadata_fields
      field :view, as: :number, readonly: true
      field :stars_count, as: :number, readonly: true
      field :project_submission, as: :boolean
      field :created_at, as: :date_time, readonly: true, sortable: true
      field :updated_at, as: :date_time, readonly: true
    end

    def relationship_fields
      belongs_to_fields
      many_relationship_fields
      single_relationship_fields
    end

    def belongs_to_fields
      field :author, as: :belongs_to, searchable: true
      field :assignment, as: :belongs_to
      field :forked_project, as: :belongs_to, use_resource: "Avo::Resources::Project"
    end

    def many_relationship_fields
      field :forks, as: :has_many
      field :stars, as: :has_many
      field :user_ratings, as: :has_many, through: :stars
      field :collaborations, as: :has_many
      field :collaborators, as: :has_many, through: :collaborations
      field :submissions, as: :has_many
      field :taggings, as: :has_many
      field :tags, as: :has_many
      field :tag_list, as: :text, help: "Comma-separated tags"
    end

    def single_relationship_fields
      field :featured_circuit, as: :has_one
      field :grade, as: :has_one
      field :project_datum, as: :has_one
      field :contest_winner, as: :has_one
    end

    def file_fields
      field :image_preview, as: :file, is_image: true
      field :circuit_preview, as: :file
    end

  public

  def filters
    filter Avo::Filters::ProjectAccessType
    filter Avo::Filters::ProjectFeatured
  end

  def actions
    action Avo::Actions::ToggleFeaturedProject
    action Avo::Actions::ExportProject
  end
end
