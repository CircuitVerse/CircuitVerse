# frozen_string_literal: true

class Avo::Resources::Contest < Avo::BaseResource
  self.model_class = ::Contest
  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_record: true

    field :deadline,
          as: :date_time,
          required: true,
          help: "Contest deadline (must be in the future)"

    field :status,
          as: :badge,
          colors: {
            live: :success,
            completed: :gray
          },
          except_on: %i[new edit]

    field :status,
          as: :select,
          only_on: %i[new edit],
          options: -> { resource.status_options },
          required: true,
          help: "Only one contest can be live at a time"

    field :created_at, as: :date_time, hide_on: %i[new edit]
    field :updated_at, as: :date_time, hide_on: %i[new edit]
  end

  # rubocop:enable Metrics/MethodLength

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
