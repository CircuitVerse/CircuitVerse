module Commontator::JsonArrayCoder
  def self.load(data)
    obj = JSON.load(data)
    obj.is_a?(Array) ? obj : []
  end

  def self.dump(obj)
    obj.is_a?(Array) ? JSON.dump(obj) : '[]'
  end
end
