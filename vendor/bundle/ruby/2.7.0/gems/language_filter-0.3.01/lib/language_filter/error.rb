module LanguageFilter
  class Error < RuntimeError; end

  class UnkownContent     < Error; end
  class UnkownContentFile < Error; end
  class EmptyContentList  < Error; end
end