# frozen_string_literal: true

class Avo::Resources::Assignment < Avo::BaseResource
  GRADING_SCALE_OPTIONS = {
    "no_scale" => "No Scale",
    "letter" => "Letter (A-F)",
    "percent" => "Percent (0-100)",
    "custom" => "Custom"
  }.freeze

  self.model_class = ::Assignment
  self.title = :name
  self.includes = %i[group projects grades]

  def fields
    field :id, as: :id, link_to_record: true

    assignment_fields
    lti_fields
    association_fields
    timestamp_fields
  end

  private

  def assignment_fields
    field :name, as: :text,
                 required: true,
                 sortable: true

    field :deadline, as: :date_time,
                     required: true,
                     sortable: true,
                     help: "Assignment submission deadline"

    field :description, as: :textarea

    field :grading_scale, as: :select,
                          enum: GRADING_SCALE_OPTIONS,
                          required: true,
                          help: "How this assignment should be graded"

    field :restrictions, as: :textarea,
                         help: "JSON array of restricted circuit elements"

    field :status, as: :text
  end

  def lti_fields
    field :lti_consumer_key, as: :text,
                             help: "LTI consumer key for LMS integration"

    field :lti_shared_secret, as: :password,
                              hide_on: %i[index show],
                              help: "LTI shared secret for LMS integration"
  end

  def association_fields
    field :group, as: :belongs_to,
                  required: true,
                  sortable: true,
                  hide_on: [:index]

    field :projects, as: :has_many,
                     attach_scope: -> { query.where(project_access_type: "Private") },
                     help: "Only Private projects can be attached to an assignment",
                     show_on: %i[edit]

    field :grades, as: :has_many,
                   show_on: %i[edit]

  end

  def timestamp_fields
    field :created_at, as: :date_time,
                       hide_on: %i[edit new],
                       sortable: true

    field :updated_at, as: :date_time,
                       hide_on: %i[edit new]
  end
end
