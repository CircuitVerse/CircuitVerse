# frozen_string_literal: true

class Avo::Resources::Contest < Avo::BaseResource
  STATUS_BADGE_COLORS = {
    live: :success,
    completed: :gray
  }.freeze

  self.model_class = ::Contest
  self.includes = %i[submissions submission_votes contest_winner]

  def fields
    field :id, as: :id, link_to_record: true

    deadline_field
    status_fields
    association_fields
    timestamp_fields
  end

  def deadline_field
    field :deadline,
          as: :date_time,
          required: true,
          help: "Contest deadline (must be in the future)"
  end

  def status_fields
    field :status,
          as: :badge,
          colors: STATUS_BADGE_COLORS,
          except_on: %i[new edit]

    field :status,
          as: :select,
          only_on: %i[new edit],
          options: -> { resource.status_options },
          required: true,
          help: "Only one contest can be live at a time"
  end

  def timestamp_fields
    field :created_at, as: :date_time, hide_on: %i[new edit]
    field :updated_at, as: :date_time, hide_on: %i[new edit]
  end

  def association_fields
    field :submissions, as: :has_many, show_on: %i[edit]
    field :submission_votes, as: :has_many, show_on: %i[edit]
    field :contest_winner, as: :has_one, show_on: %i[edit]
  end

  def status_options
    live_exists = Contest.live.exists?

    return { "Completed" => "completed" } if view == :new && live_exists

    if view == :edit && record&.live?
      return {
        "Live" => "live",
        "Completed" => "completed"
      }
    end

    return { "Completed" => "completed" } if view == :edit && live_exists

    {
      "Completed" => "completed",
      "Live" => "live"
    }
  end
end
