require_relative 'config'

class Commontator::CommontableConfig
  Commontator::Config::COMMONTABLE_ATTRIBUTES.each do |attribute|
    attr_accessor attribute
  end

  # For backwards-compatibility with Integer comments_per_page
  def comments_per_page=(cpp)
    @comments_per_page = [ cpp ].flatten
  end

  def initialize(options = {})
    Commontator::Config::COMMONTABLE_ATTRIBUTES.each do |attribute|
      send "#{attribute}=", options[attribute] || Commontator.send(attribute)
    end
  end
end
