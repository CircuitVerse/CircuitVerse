module Lookbook
  class CodeIndenter < Service
    def initialize(source)
      @source = source.to_s
    end

    def call
      source = @source.chomp
      last = source.split(/\r?\n/).last
      indent = last ? last[/^([ \t]*)/, 1].length : 0
      source.gsub(/^[ \t]{#{indent}}/, "")
    end
  end
end
