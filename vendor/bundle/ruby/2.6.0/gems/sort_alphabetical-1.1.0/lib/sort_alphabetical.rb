# TODO do something like with_utf8 do ...

require 'unicode_utils/compatibility_decomposition'
require 'unicode_utils/general_category'
require 'sort_alphabetical/core_ext'

module SortAlphabetical
  extend self

  def sort(set)
    set.sort_by do |item|
      if block_given?
        item = yield(item).to_s
      else
        item = item.to_s
      end
      [normalize(item), item] # when both á and a are present, sort them a, á
    end
  end

  def normalize(string)
    result = String.new
    UnicodeUtils.compatibility_decomposition(string).each_char do |c|
      if UnicodeUtils.general_category(c) =~ /Letter|Separator|Punctuation|Number/
        result << c
      end
    end
    result
  end
end
