# frozen_string_literal: true

class Avo::Resources::Grade < Avo::BaseResource
  self.model_class = ::Grade
  self.title = :id
  self.includes = %i[project grader assignment]

  self.search = {
    query: lambda {
      query.joins(:grader, :project)
           .where("users.name ILIKE ? OR users.email ILIKE ? OR projects.name ILIKE ?",
                  "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%")
    }
  }
  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_record: true

    # Associations
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

    # Grade fields with dynamic help based on assignment
    field :grade, as: :text,
                  required: true,
                  help: lambda {
                    if record.assignment.present?
                      # rubocop:disable Style/HashLikeCase
                      case record.assignment.grading_scale
                      when "no_scale"
                        "⚠️ This assignment cannot be graded (no_scale)"
                      when "letter"
                        "Enter a letter grade: A, B, C, D, E, or F"
                      when "percent"
                        "Enter a percentage: 0-100"
                      when "custom"
                        "Enter any custom grade value"
                      end
                      # rubocop:enable Style/HashLikeCase
                    else
                      "Grade value (format depends on assignment's grading scale)"
                    end
                  }

    field :remarks, as: :textarea,
                    help: "Additional comments or feedback for the student"

    # Timestamps
    field :created_at, as: :date_time,
                       hide_on: %i[edit new],
                       sortable: true

    field :updated_at, as: :date_time,
                       hide_on: %i[edit new]

    # Display grading scale info
    field :grading_scale_info, as: :text,
                               hide_on: %i[edit new],
                               format_using: lambda {
                                 assignment = record.assignment
                                 case assignment&.grading_scale
                                 when "no_scale" then "🚫 No Scale"
                                 when "letter" then "🔤 Letter (A-F)"
                                 when "percent" then "📊 Percent (0-100)"
                                 when "custom" then "✏️ Custom"
                                 else "Unknown"
                                 end
                               }
  end
  # rubocop:enable Metrics/MethodLength

  def filters
    filter Avo::Filters::GradeByAssignment
    filter Avo::Filters::GradeByGrader
    filter Avo::Filters::GradeByScale
  end

  def actions
    action Avo::Actions::ExportGradesToCsv
  end
end
