class Avo::Resources::TestCase < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :assignment, as: :belongs_to
    field :input, as: :textarea
    field :expected_output, as: :textarea
    field :description, as: :textarea
  end
end
