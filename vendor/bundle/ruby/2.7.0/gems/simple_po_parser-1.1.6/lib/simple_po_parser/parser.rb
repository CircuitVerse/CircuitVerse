# encoding: utf-8

module SimplePoParser
  # Fast parser directly using Rubys powerful StringScanner (strscan)
  #
  # Important notes about StringScanner.scan:
  # * scan will return nil if there is no match. Using the regex * (zero or more) quantifier will
  #  let scan return an empty string if there is "no match" as the empty string qualifies as
  #  a match of the regex (zero times). We make use of this "trick"
  # * the start of line anchor ^ is obsolete as scan will only match start of line.
  # * rubys regex is by default in single-line mode, therefore scan will only match until
  #  the next newline is hit (unless multi-line mode is explicitly enabled)
  class Parser
    require_relative 'error'
    require 'strscan'

    # parse a single message of the PO format.
    #
    # @param message a single PO message in String format without leading or trailing whitespace
    # @return [Hash] parsed PO message information in Hash format
    def parse(message)
      @result = {}
      @scanner = StringScanner.new(message.strip)
      begin
        lines
      rescue ParserError => pe
        error_msg = "SimplePoParser::ParserError"
        error_msg += pe.message
        error_msg += "\nParseing result before error: '#{@result}'"
        error_msg += "\nSimplePoParser filtered backtrace: SimplePoParser::ParserError"
        backtrace = "#{pe.backtrace.select{|i| i =~ /lib\/simple_po_parser/}.join("\n\tfrom ")}"
        raise ParserError, error_msg, backtrace
      end
      @result
    end

    private

    #########################################
    ###            branching              ###
    #########################################

    # arbitary line of a PO message. Can be comment or message
    # message parsing is always started with checking for msgctxt as content is expected in
    # msgctxt -> msgid -> msgid_plural -> msgstr order
    def lines
      begin
        if @scanner.scan(/#/)
          comment
        else
          msgctxt
        end
      rescue PoSyntaxError => pe
        # throw a normal ParserError to break the recursion
        raise ParserError, "Syntax error in lines\n" + pe.message, pe.backtrace
      end
    end

    # match a comment line. called on lines starting with '#'.
    # Recalls line when the comment line was parsed
    def comment
      begin
        case @scanner.getch
        when ' '
          skip_whitespace
          add_result(:translator_comment, comment_text)
          lines
        when '.'
          skip_whitespace
          add_result(:extracted_comment, comment_text)
          lines
        when ':'
          skip_whitespace
          add_result(:reference, comment_text)
          lines
        when ','
          skip_whitespace
          add_result(:flag, comment_text)
          lines
        when '|'
          skip_whitespace
          previous_comments
          lines
        when "\n"
          add_result(:translator_comment, "") # empty comment line
          lines
        when '~'
          if @result[:previous_msgctxt] || @result[:previous_msgid] || @result[:previous_msgid_plural]
            raise PoSyntaxError, "Previous comment entries need to be marked obsolete too in obsolete message entries. But already got: #{@result}"
          end
          skip_whitespace
          add_result(:obsolete, comment_text)
          obsoletes
        else
          @scanner.pos = @scanner.pos - 2
          raise PoSyntaxError, "Unknown comment type #{@scanner.peek(10).inspect}"
        end
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in comment\n" + pe.message, pe.backtrace
      end
    end

    # matches the msgctxt line and will continue to check for msgid afterwards
    #
    # msgctxt is optional
    def msgctxt
      begin
        if @scanner.scan(/msgctxt/)
          skip_whitespace
          text = message_line
          add_result(:msgctxt, text)
          message_multiline(:msgctxt) if @scanner.peek(1) == '"'
        end
        msgid
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in msgctxt\n" + pe.message, pe.backtrace
      end
    end

    # matches the msgid line. Will check for optional msgid_plural.
    # Will advance to msgstr or msgstr_plural based on msgid_plural
    #
    # msgid is required
    def msgid
      begin
        if @scanner.scan(/msgid/)
          skip_whitespace
          text = message_line
          add_result(:msgid, text)
          message_multiline(:msgid) if @scanner.peek(1) == '"'
          if msgid_plural
            msgstr_plural
          else
            msgstr
          end
        else
          err_msg = "Message without msgid is not allowed."
          err_msg += "The Line started unexpectedly with #{@scanner.peek(10).inspect}."
          raise PoSyntaxError, err_msg
        end
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in msgid\n" + pe.message, pe.backtrace
      end

    end

    # matches the msgid_plural line.
    #
    # msgid_plural is optional
    #
    # @return [boolean] true if msgid_plural is present, false otherwise
    def msgid_plural
      begin
        if @scanner.scan(/msgid_plural/)
          skip_whitespace
          text = message_line
          add_result(:msgid_plural, text)
          message_multiline(:msgid_plural) if @scanner.peek(1) == '"'
          true
        else
          false
        end
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in msgid\n" + pe.message, pe.backtrace
      end
    end

    # parses the msgstr singular line
    #
    # msgstr is required in singular translations
    def msgstr
      begin
        if @scanner.scan(/msgstr/)
          skip_whitespace
          text = message_line
          add_result(:msgstr, text)
          message_multiline(:msgstr) if @scanner.peek(1) == '"'
          skip_whitespace
          raise PoSyntaxError, "Unexpected content after expected message end #{@scanner.peek(10).inspect}" unless @scanner.eos?
        else
         raise PoSyntaxError, "Singular message without msgstr is not allowed. Line started unexpectedly with #{@scanner.peek(10).inspect}."
        end
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in msgstr\n" + pe.message, pe.backtrace
      end
    end

    # parses the msgstr plural lines
    #
    # msgstr plural lines are used when there is msgid_plural.
    # They have the format msgstr[N] where N is incremental number starting from zero representing
    # the plural number as specified in the headers "Plural-Forms" entry. Most languages, like the
    # English language only have two plural forms (singular and plural),
    # but there are languages with more plurals
    def msgstr_plural(num = 0)
      begin
        msgstr_key = @scanner.scan(/msgstr\[\d\]/) # matches 'msgstr[0]' to 'msgstr[9]'
        if msgstr_key
          # msgstr plurals must come in 0-based index in order
          msgstr_num = msgstr_key.match(/\d/)[0].to_i
          raise PoSyntaxError, "Bad 'msgstr[index]' index." if msgstr_num != num
          skip_whitespace
          text = message_line
          add_result(msgstr_key, text)
          message_multiline(msgstr_key) if @scanner.peek(1) == '"'
          msgstr_plural(num+1)
        elsif num == 0 # and msgstr_key was false
          raise PoSyntaxError, "Plural message without msgstr[0] is not allowed. Line started unexpectedly with #{@scanner.peek(10).inspect}."
        else
          raise PoSyntaxError, "End of message was expected, but line started unexpectedly with #{@scanner.peek(10).inspect}" unless @scanner.eos?
        end
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in msgstr_plural\n" + pe.message, pe.backtrace
      end
    end

    # parses previous comments, which provide additional information on fuzzy matching
    #
    # previous comments are:
    # * #| msgctxt
    # * #| msgid
    # * #| msgid_plural
    def previous_comments
      begin
        # next part must be msgctxt, msgid or msgid_plural
        if @scanner.scan(/msg/)
          if @scanner.scan(/id/)
            if @scanner.scan(/_plural/)
              key = :previous_msgid_plural
            else
              key = :previous_msgid
            end
          elsif @scanner.scan(/ctxt/)
            key = :previous_msgctxt
          else
            raise PoSyntaxError, "Previous comment type #{("msg" + @scanner.peek(10)).inspect} unknown."
          end
          skip_whitespace
          text = message_line
          add_result(key, text)
          previous_multiline(key) if @scanner.match?(/#\|\p{Blank}*"/)
        else
          raise PoSyntaxError, "Previous comments must start with '#| msg'. #{@scanner.peek(10).inspect} unknown."
        end
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in previous_comments\n" + pe.message, pe.backtrace
      end
    end

    # parses the multiline messages of the previous comment lines
    def previous_multiline(key)
      begin
        # scan multilines until no further multiline is hit
        # /#\|\p{Blank}"/ needs to catch the double quote to ensure it hits a previous
        # multiline and not another line type.
        if @scanner.scan(/#\|\p{Blank}*"/)
          @scanner.pos = @scanner.pos - 1 # go one character back, so we can reuse the "message line" method
          add_result(key, message_line)
          previous_multiline(key) # go on until we no longer hit a multiline line
        end
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in previous_multiline\n" + pe.message, pe.backtrace
      end
    end

    # parses a multiline message
    #
    # Multiline messages are usually indicated by an empty string as the first line,
    # followed by more lines starting with the double quote character.
    #
    # However, according to the PO file standard, the first line can also contain content.
    def message_multiline(key)
      begin
        skip_whitespace
        if @scanner.check(/"/)
          add_result(key, message_line)
          message_multiline(key)
        end
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in message_multiline with key '#{key}'\n" + pe.message, pe.backtrace
      end
    end

    # identifies a message line and returns it's text or raises an error
    #
    # @return [String] message_text
    def message_line
      begin
        if @scanner.getch == '"'
          text = message_text
          unless @scanner.getch == '"'
            err_msg = "The message text '#{text}' must be finished with the double quote character '\"'."
            raise PoSyntaxError, err_msg
          end
          skip_whitespace
          unless end_of_line
            err_msg = "There should be only whitespace until the end of line"
            err_msg += " after the double quote character of a message text."
            raise PoSyntaxError.new(err_msg)
          end
          text
        else
          @scanner.pos = @scanner.pos - 1
          err_msg = "A message text needs to start with the double quote character '\"',"
          err_msg += " but this was found: #{@scanner.peek(10).inspect}"
          raise PoSyntaxError, err_msg
        end
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in message_line\n" + pe.message, pe.backtrace
      end
    end

    # parses all obsolete lines.
    # An obsolete message may only contain obsolete lines
    def obsoletes
      if @scanner.scan(/#~/)
        skip_whitespace
        add_result(:obsolete, comment_text)
        obsoletes
      else
        raise PoSyntaxError, "All lines must be obsolete after the first obsolete line, but got #{@scanner.peek(10).inspect}." unless @scanner.eos?
      end
    end

    #########################################
    ###             scanning              ###
    #########################################

    # returns the text of a comment
    #
    # @return [String] text
    def comment_text
      begin
        text = @scanner.scan(/.*/) # everything until newline
        text.rstrip! # benchmarked faster too rstrip the string in place
        raise PoSyntaxError, "Comment text should advance to next line or stop at eos" unless end_of_line
        text
      rescue PoSyntaxError => pe
        raise PoSyntaxError, "Syntax error in commtent_text\n" + pe.message, pe.backtrace
      end
    end

    # returns the text of a message line
    #
    # @return [String] text
    def message_text
      @scanner.scan_until(/(\\(\\|")|[^"])*/) # this parses anything until an unescaped quote is hit
    end

    # advances the scanner until the next non whitespace position.
    # Does not match newlines. See WHITESPACE_REGEX constant
    def skip_whitespace
      @scanner.skip(/\p{Blank}+/)
    end

    # returns true if the scanner is at beginning of next line or end of string
    #
    # @return [Boolean] true if scanner at beginning of line or eos
    def end_of_line
      @scanner.scan(/\n/)
      @scanner.eos? || @scanner.bol?
    end

    # adds text to the given key in results
    # creates an array if the given key already has a result
    def add_result(key, text)
      if @result[key]
        if @result[key].is_a? Array
          @result[key].push(text)
        else
          @result[key] = [@result[key], text]
        end
      else
        @result[key] = text
      end
    end
  end
end
