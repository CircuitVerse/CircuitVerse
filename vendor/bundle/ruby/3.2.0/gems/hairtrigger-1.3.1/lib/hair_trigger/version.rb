module HairTrigger
  VERSION = "1.3.1"

  def VERSION.<=>(other)
    split(/\./).map(&:to_i) <=> other.split(/\./).map(&:to_i)
  end
end
