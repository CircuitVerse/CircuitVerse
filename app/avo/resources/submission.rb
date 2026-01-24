# frozen_string_literal: true

class Avo::Resources::Submission < Avo::BaseResource
  self.title = :id
  self.includes = %i[contest project user submission_votes contest_winner]

  self.search = {
    query: lambda {
      query.where("CAST(id AS TEXT) LIKE ?", "%#{params[:q]}%")
    }
  }

  def fields
    field :id, as: :id, link_to_record: true

    # Associations
    field :contest, as: :belongs_to, required: true
    field :project, as: :belongs_to, required: true
    field :user, as: :belongs_to, required: true

    # Winner status
    field :winner, as: :boolean, help: "Is this submission the winner?"

    # Timestamps
    field :created_at, as: :date_time, hide_on: %i[edit new], sortable: true
    field :updated_at, as: :date_time, hide_on: %i[edit new]

    # Related associations
    field :submission_votes, as: :has_many,
                             show_on: :show,
                             description: "Votes for this submission"

    field :contest_winner, as: :has_one,
                           show_on: :show,
                           description: "Winner record if this submission won"
  end

  def filters
    filter Avo::Filters::WinnerFilter
  end
end
