# encoding: utf-8

require 'pathname'
require 'language_filter/error'
require 'language_filter/version'

module LanguageFilter
  class Filter
    attr_accessor :matchlist, :exceptionlist, :replacement, :creative_letters
    attr_reader :creative_matchlist

    CREATIVE_BEG_REGEX = '(?<=\\s|\\A|_|\\-|\\.)'
    CREATIVE_END_REGEX = '(?=\\b|\\s|\\z|_|\\-|\\.)'

    DEFAULT_EXCEPTIONLIST = []
    DEFAULT_MATCHLIST = File.dirname(__FILE__) + "/../config/matchlists/profanity.txt"
    DEFAULT_REPLACEMENT = :stars
    DEFAULT_CREATIVE_LETTERS = false

    def initialize(options={})
      @creative_letters = if options[:creative_letters] then
        options[:creative_letters]
      else DEFAULT_CREATIVE_LETTERS end

      @matchlist = if options[:matchlist] then
        validate_list_content(options[:matchlist])
        set_list_content(options[:matchlist])
      else set_list_content(DEFAULT_MATCHLIST) end
      @creative_matchlist = @matchlist.map {|list_item| use_creative_letters(list_item)}

      @exceptionlist = if options[:exceptionlist] then
        validate_list_content(options[:exceptionlist])
        set_list_content(options[:exceptionlist])
      elsif options[:matchlist].class == Symbol then
        set_list_content(options[:matchlist],folder: "exceptionlists")
      else set_list_content(DEFAULT_EXCEPTIONLIST) end

      @replacement = options[:replacement] || DEFAULT_REPLACEMENT
      validate_replacement
    end

    # SETTERS

    def matchlist=(content)
      validate_list_content(content)
      @matchlist = case content 
      when :default then set_list_content(DEFAULT_MATCHLIST)
      else set_list_content(content)
      end
      @exceptionlist = set_list_content(content,folder: "exceptionlists") if content.class == Symbol and @exceptionlist.empty?
      @creative_matchlist = @matchlist.map {|list_item| use_creative_letters(list_item)}
    end

    def exceptionlist=(content)
      validate_list_content(content)
      @exceptionlist = case content 
      when :default then set_list_content(DEFAULT_EXCEPTIONLIST)
      else set_list_content(content)
      end
    end

    def replacement=(value)
      @replacement = case value 
      when :default then :stars
      else value
      end
      validate_replacement
    end

    # LANGUAGE

    def match?(text)
      return false unless text.to_s.size >= 3
      chosen_matchlist = case @creative_letters
      when true then @creative_matchlist
      else @matchlist
      end
      chosen_matchlist.each do |list_item|
        start_at = 0
        text.scan(%r"#{beg_regex}#{list_item}#{end_regex}"i) do |match|
          unless @exceptionlist.empty? then
            match_start = text[start_at..-1].index(%r"#{beg_regex}#{list_item}#{end_regex}"i) + start_at
            match_end = match_start + match.size-1
          end
          return true if @exceptionlist.empty? or not protected_by_exceptionlist?(match_start,match_end,text,start_at)
          start_at = match_end + 1 unless @exceptionlist.empty?
        end
      end
      false
    end

    def matched(text)
      words = []
      return words unless text.to_s.size >= 3
      chosen_matchlist = case @creative_letters
      when true then @creative_matchlist
      else @matchlist
      end
      chosen_matchlist.each do |list_item|
        start_at = 0
        text.scan(%r"#{beg_regex}#{list_item}#{end_regex}"i) do |match|
          unless @exceptionlist.empty? then
            match_start = text[start_at..-1].index(%r"#{beg_regex}#{list_item}#{end_regex}"i) + start_at
            match_end = match_start + match.size-1
          end
          words << match if @exceptionlist.empty? or not protected_by_exceptionlist?(match_start,match_end,text,start_at)
          start_at = match_end + 1 unless @exceptionlist.empty?
        end
      end
      words.uniq
    end

    def sanitize(text)
      return text unless text.to_s.size >= 3
      chosen_matchlist = case @creative_letters
      when true then @creative_matchlist
      else @matchlist
      end
      chosen_matchlist.each do |list_item|
        start_at = 0
        text.gsub!(%r"#{beg_regex}#{list_item}#{end_regex}"i) do |match|
          unless @exceptionlist.empty? then
            match_start = text[start_at..-1].index(%r"#{beg_regex}#{list_item}#{end_regex}"i) + start_at
            match_end = match_start + match.size-1
          end
          unless @exceptionlist.empty? or not protected_by_exceptionlist?(match_start,match_end,text,start_at) then
            start_at = match_end + 1 unless @exceptionlist.empty?
            match
          else
            start_at = match_end + 1 unless @exceptionlist.empty?
            replace(match)
          end
        end
      end
      text
    end

    private

    # VALIDATIONS

    def validate_list_content(content)
      case content
      when Array    then content.all? {|c| c.class == String} || raise(LanguageFilter::EmptyContentList.new("List content array is empty."))
      when String   then File.exists?(content)                || raise(LanguageFilter::UnkownContentFile.new("List content file \"#{content}\" can't be found."))
      when Pathname then content.exist?                       || raise(LanguageFilter::UnkownContentFile.new("List content file \"#{content}\" can't be found."))
      when Symbol   then
        case content
        when :default, :hate, :profanity, :sex, :violence then true
        else raise(LanguageFilter::UnkownContent.new("The only accepted symbols are :default, :hate, :profanity, :sex, and :violence."))
        end
      else raise LanguageFilter::UnkownContent.new("The list content can be either an Array, Pathname, or String path to a file.")
      end
    end

    def validate_replacement
      case @replacement
      when :default, :garbled, :vowels, :stars, :nonconsonants
      else raise LanguageFilter::UnknownReplacement.new("This is not a known replacement type.")
      end
    end

    # HELPERS

    def set_list_content(list,options={})
      case list
      when :hate      then load_list File.dirname(__FILE__) + "/../config/#{options[:folder] || "matchlists"}/hate.txt"
      when :profanity then load_list File.dirname(__FILE__) + "/../config/#{options[:folder] || "matchlists"}/profanity.txt"
      when :sex       then load_list File.dirname(__FILE__) + "/../config/#{options[:folder] || "matchlists"}/sex.txt"
      when :violence  then load_list File.dirname(__FILE__) + "/../config/#{options[:folder] || "matchlists"}/violence.txt"
      when Array then list.map {|list_item| list_item.gsub(/(?<=[^\\]|\A)\((?=[^(\?\:)])/,'(?:')}
      when String, Pathname then load_list list.to_s
      else []
      end
    end

    def load_list(filepath)
      IO.readlines(filepath).each {|line| line.gsub!(/\n/,''); line.gsub!(/(?<=[^\\]|\A)\((?=[^(\?\:)])/,'(?:')}
    end

    def use_creative_letters(text)
      new_text = ""
      last_char = ""
      first_char_done = false
      text.each_char do |char|
        if last_char != '\\'
          # new_text += '[\\-_\\s\\*\\.\\,\\`\\:\\\']*' if last_char != "" and char =~ /[A-Za-z]/ and first_char_done
          new_text += case char.downcase
          when 'a' then first_char_done = true; '(?:(?:a|@|4|\\^|/\\\\|/\\-\\\\|aye?)+)'
          when 'b' then first_char_done = true; '(?:(?:b|i3|l3|13|\\|3|/3|\\\\3|3|8|6|\\u00df|p\\>|\\|\\:|[^a-z]bee+[^a-z])+)'
          when 'c','k' then first_char_done = true; '(?:(?:c|\\u00a9|\\u00a2|\\(|\\[|[^a-z]cee+[^a-z]|[^a-z]see+[^a-z]|k|x|[\\|\\[\\]\\)\\(li1\\!\\u00a1][\\<\\{\\(]|[^a-z][ck]ay+[^a-z])+)'
          when 'd' then first_char_done = true; '(?:(?:d|\\)|\\|\\)|\\[\\)|\\?|\\|\\>|\\|o|[^a-z]dee+[^a-z])+)'
          when 'e' then first_char_done = true; '(?:(?:e|3|\\&|\\u20ac|\\u00eb|\\[\\-)+)'
          when 'f' then first_char_done = true; '(?:(?:f|ph|\\u0192|[\\|\\}\\{\\\\/\\(\\)\\[\\]1il\\!][\\=\\#]|[^a-z]ef+[^a-z])+)'
          when 'g' then first_char_done = true; '(?:(?:g|6|9|\\&|c\\-|\\(_\\+|[^a-z]gee+[^a-z])+)'
          when 'h' then first_char_done = true; '(?:(?:h|\\#|[\\|\\}\\{\\\\/\\(\\)\\[\\]]\\-?[\\|\\}\\{\\\\/\\(\\)\\[\\]])+)'
          when 'i','l' then first_char_done = true; '(?:(?:i|l|1|\\!|\\u00a1|\\||\\]|\\[|\\\\|/|[^a-z]eye[^a-z]|\\u00a3|[\\|li1\\!\\u00a1\\[\\]\\(\\)\\{\\}]_|\\u00ac|[^a-z]el+[^a-z]))'
          when 'j' then first_char_done = true; '(?:(?:j|\\]|\\u00bf|_\\||_/|\\</|\\(/|[^a-z]jay+[^a-z])+)'
          when 'm' then first_char_done = true; '(?:(?:m|[\\|\\(\\)/](?:\\\\/|v|\\|)[\\|\\(\\)\\\\]|\\^\\^|[^a-z]em+[^a-z])+)'
          when 'n' then first_char_done = true; '(?:(?:n|[\\|/\\[\\]\\<\\>]\\\\[\\|/\\[\\]\\<\\>]|/v|\\^/|[^a-z]en+[^a-z])+)'
          when 'o' then first_char_done = true; '(?:(?:o|0|\\(\\)|\\[\\]|\\u00b0|[^a-z]oh+[^a-z])+)'
          when 'p' then first_char_done = true; '(?:(?:p|\\u00b6|[\\|li1\\[\\]\\!\\u00a1/\\\\][\\*o\\u00b0\\"\\>7\\^]|[^a-z]pee+[^a-z])+)'
          when 'q' then first_char_done = true; '(?:(?:q|9|(?:0|\\(\\)|\\[\\])_|\\(_\\,\\)|\\<\\||[^a-z][ck]ue*|qu?eue*[^a-z])+)'
          when 'r' then first_char_done = true; '(?:(?:r|[/1\\|li]?[2\\^\\?z]|\\u00ae|[^a-z]ar+[^a-z])+)'
          when 's','z' then first_char_done = true; '(?:(?:s|\\$|5|\\u00a7|[^a-z]es+[^a-z]|z|2|7_|\\~/_|\\>_|\\%|[^a-z]zee+[^a-z])+)'
          when 't' then first_char_done = true; '(?:(?:t|7|\\+|\\u2020|\\-\\|\\-|\\\'\\]\\[\\\')+)'
          when 'u','v' then first_char_done = true; '(?:(?:u|v|\\u00b5|[\\|\\(\\)\\[\\]\\{\\}]_[\\|\\(\\)\\[\\]\\{\\}]|\\L\\||\\/|[^a-z]you[^a-z]|[^a-z]yoo+[^a-z]|[^a-z]vee+[^a-z]))'
          when 'w' then first_char_done = true; '(?:(?:w|vv|\\\\/\\\\/|\\\\\\|/|\\\\\\\\\\\'|\\\'//|\\\\\\^/|\\(n\\)|[^a-z]do?u+b+l+e*[^a-z]?(?:u+|you|yoo+)[^a-z])+)'
          when 'x' then first_char_done = true; '(?:(?:x|\\>\\<|\\%|\\*|\\}\\{|\\)\\(|[^a-z]e[ck]+s+[^a-z]|[^a-z]ex+[^a-z])+)'
          when 'y' then first_char_done = true; '(?:(?:y|\\u00a5|j|\\\'/|[^a-z]wh?(?:y+|ie+)[^a-z])+)'
          else char
          end
        elsif char.downcase == 'w' then
          new_text += 'S'
        else
          new_text += char
        end
        last_char = char
      end
      new_text
    end

    def protected_by_exceptionlist?(match_start,match_end,text,start_at)
      @exceptionlist.each do |list_item|
        current_start_at = start_at
        done_searching = false
        until done_searching do
          # puts "#{current_start_at}"
          text_snippet = text[current_start_at..-1]
          exception_start = text_snippet.index(%r"\b#{list_item}\b"i)
          # puts "#{text_snippet[%r`\b#{list_item}\b`i]}, #{text[match_start..match_end]} :: #{current_start_at}, #{text.size} :: #{match_start}, #{match_end}" if text[match_start..match_end] == "XIII"
          if exception_start then
            exception_start += current_start_at
            # puts "#{text_snippet[%r`\b#{list_item}\b`i]}, #{text[match_start..match_end]} :: #{current_start_at}, #{text.size} :: #{match_start}, #{match_end} :: #{exception_start}, #{text[exception_start,20]}" if text[match_start..match_end] == "XIII"
            if exception_start <= match_start then
              exception_end = exception_start + text_snippet[%r"\b#{list_item}\b"i].size-1
              # puts "#{text_snippet[%r`\b#{list_item}\b`i]}, #{text[match_start..match_end]} :: #{current_start_at}, #{text.size} :: #{match_start}, #{match_end} :: #{exception_start}, #{exception_end}"
              if exception_end >= match_end
                return true
              elsif text[exception_end+1..-1].index(%r"\b#{list_item}\b"i)
                current_start_at = exception_end+1
              else
                done_searching = true
              end
            else
              done_searching = true
            end
          else
            done_searching = true
          end
          # puts text[exception_end+1..-1].index(%r"\b#{list_item}\b"i).inspect
        end
      end
      return false
    end

    # This was moved to private because users should just use sanitize for any content
    def replace(word)
      case @replacement
      when :vowels then word.gsub(/[aeiou]/i, '*')
      when :stars  then '*' * word.size
      when :nonconsonants then word.gsub(/[^bcdfghjklmnpqrstvwxyz]/i, '*')
      when :default, :garbled then '$@!#%'
      else raise LanguageFilter::UnknownReplacement.new("#{@replacement} is not a known replacement type.")
      end
    end

    def beg_regex
      if @creative_letters then
        CREATIVE_BEG_REGEX
      else
        '\\b'
      end
    end

    def end_regex
      if @creative_letters then
        CREATIVE_END_REGEX
      else
        '\\b'
      end
    end
  end
end