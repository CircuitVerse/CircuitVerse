class Topic
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :title, :author, :body, :subtitle

  validates :title, length: { minimum: 5 }
  validates :author, presence: true
  validates :body, length: { minimum: 10 }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
