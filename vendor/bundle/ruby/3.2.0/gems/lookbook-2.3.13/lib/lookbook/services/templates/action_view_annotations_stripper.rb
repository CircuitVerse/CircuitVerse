module Lookbook
  class ActionViewAnnotationsStripper < Service
    attr_reader :text

    ANNOTATIONS_REGEX = /<!-- (BEGIN|END) (.*) -->/

    def initialize(text)
      @text = text.to_s
    end

    def call
      text.gsub(ANNOTATIONS_REGEX, "")
    end
  end
end
