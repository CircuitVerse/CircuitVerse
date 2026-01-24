# frozen_string_literal: true

class Avo::Resources::Contest < Avo::BaseResource
  self.model_class = ::Contest
  self.title = :id
  self.includes = %i[submissions submission_votes contest_winner]
  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_record: true

    field :deadline, as: :date_time,
                     required: true,
                     help: "Contest deadline (must be in the future)"

    field :status, as: :select,
                   enum: { "live" => "Live", "completed" => "Completed" },
                   required: true,
                   help: "Only one contest can be live at a time"

    field :created_at, as: :date_time,
                       hide_on: %i[edit new],
                       sortable: true

    field :updated_at, as: :date_time,
                       hide_on: %i[edit new]

    # Associations - shown on all views including new/edit
    field :submissions, as: :has_many

    field :submission_votes, as: :has_many

    field :contest_winner, as: :has_one
  end

  # rubocop:enable Metrics/MethodLength
  def filters
    filter Avo::Filters::ContestStatus
  end
end
