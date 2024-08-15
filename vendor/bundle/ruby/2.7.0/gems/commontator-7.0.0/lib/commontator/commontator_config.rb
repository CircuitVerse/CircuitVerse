require_relative 'config'

class Commontator::CommontatorConfig
  Commontator::Config::COMMONTATOR_ATTRIBUTES.each do |attribute|
    attr_accessor attribute
  end

  def initialize(options = {})
    Commontator::Config::COMMONTATOR_ATTRIBUTES.each do |attribute|
      send "#{attribute}=", options[attribute] || Commontator.send(attribute)
    end
  end
end
