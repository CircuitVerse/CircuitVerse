# frozen_string_literal: true

class Avo::Resources::Assignment < Avo::BaseResource
  self.model_class = ::Assignment
  self.title = :name
  self.includes = %i[group projects grades]
  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_record: true

    field :name, as: :text,
                 required: true,
                 sortable: true

    field :deadline, as: :date_time,
                     required: true,
                     sortable: true,
                     help: "Assignment submission deadline"

    field :description, as: :textarea

    field :grading_scale, as: :select,
                          enum: {
                            "no_scale" => "No Scale",
                            "letter" => "Letter (A-F)",
                            "percent" => "Percent (0-100)",
                            "custom" => "Custom"
                          },
                          required: true,
                          help: "How this assignment should be graded"

    field :restrictions, as: :textarea,
                         help: "JSON array of restricted circuit elements"

    field :status, as: :text

    # LTI Integration
    field :lti_consumer_key, as: :text,
                             help: "LTI consumer key for LMS integration"

    field :lti_shared_secret, as: :password,
                              help: "LTI shared secret for LMS integration"

    # Associations
    field :group, as: :belongs_to,
                  required: true,
                  sortable: true,
                  hide_on: [:index] # Hide on index page

    field :projects, as: :has_many,
                     hide_on: %i[new edit]

    field :grades, as: :has_many,
                   hide_on: %i[new edit]

    field :created_at, as: :date_time,
                       hide_on: %i[edit new],
                       sortable: true

    field :updated_at, as: :date_time,
                       hide_on: %i[edit new]
  end
  # rubocop:enable Metrics/MethodLength

  def filters
    filter Avo::Filters::AssignmentByGroup
    filter Avo::Filters::AssignmentByGradingScale
    filter Avo::Filters::AssignmentByStatus
  end
end
