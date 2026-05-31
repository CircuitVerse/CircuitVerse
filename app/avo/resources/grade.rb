# frozen_string_literal: true

class Avo::Resources::Grade < Avo::BaseResource
  GRADE_HELP_MESSAGES = {
    "no_scale" => "This assignment cannot be graded (no_scale)",
    "letter" => "Enter a letter grade: A, B, C, D, E, or F",
    "percent" => "Enter a percentage: 0-100",
    "custom" => "Enter any custom grade value"
  }.freeze

  GRADING_SCALE_LABELS = {
    "no_scale" => "No Scale",
    "letter" => "Letter (A-F)",
    "percent" => "Percent (0-100)",
    "custom" => "Custom"
  }.freeze

  DEFAULT_GRADE_HELP = "Grade value (format depends on assignment's grading scale)"

  self.model_class = ::Grade
  self.title = :id
  self.includes = %i[project grader assignment]

  self.search = {
    query: lambda {
      term = ActiveRecord::Base.sanitize_sql_like(params[:q].to_s)

      query.joins(:grader, :project)
           .where(
             "users.name ILIKE ? OR users.email ILIKE ? OR projects.name ILIKE ?",
             "%#{term}%",
             "%#{term}%",
             "%#{term}%"
           )
    }
  }
  def fields
    field :id, as: :id, link_to_record: true

    association_fields
    grade_fields
    timestamp_fields
    grading_scale_info_field
  end

  def association_fields
    field :assignment, as: :belongs_to,
                       required: true,
                       sortable: true,
                       help: "The assignment this grade belongs to"

    field :project, as: :belongs_to,
                    required: true,
                    sortable: true,
                    help: "Must belong to the selected assignment"

    field :grader, as: :belongs_to,
                   required: true,
                   sortable: true,
                   help: "User who assigned this grade"
  end

  def grade_fields
    field :grade, as: :text,
                  required: true,
                  help: -> { resource.grade_help_text }

    field :remarks, as: :textarea,
                    help: "Additional comments or feedback for the student"
  end

  def timestamp_fields
    field :created_at, as: :date_time,
                       hide_on: %i[edit new],
                       sortable: true

    field :updated_at, as: :date_time,
                       hide_on: %i[edit new]
  end

  def grading_scale_info_field
    field :grading_scale_info, as: :text,
                               hide_on: %i[edit new],
                               format_using: -> { resource.grading_scale_info_text }
  end

  def grade_help_text
    scale = record.assignment&.grading_scale
    GRADE_HELP_MESSAGES.fetch(scale, DEFAULT_GRADE_HELP)
  end

  def grading_scale_info_text
    scale = record.assignment&.grading_scale
    GRADING_SCALE_LABELS.fetch(scale, "Unknown")
  end
end
