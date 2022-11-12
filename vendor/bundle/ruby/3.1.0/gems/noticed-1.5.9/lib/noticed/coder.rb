module Noticed
  class Coder
    def self.load(data)
      return if data.nil?
      ActiveJob::Arguments.send(:deserialize_argument, data)
    end

    def self.dump(data)
      return if data.nil?
      ActiveJob::Arguments.send(:serialize_argument, data)
    end
  end
end
