module Lookbook
  class LogicalPathTag < YardTag
    def value
      PathUtils.strip_slashes(super)
    end
  end
end
