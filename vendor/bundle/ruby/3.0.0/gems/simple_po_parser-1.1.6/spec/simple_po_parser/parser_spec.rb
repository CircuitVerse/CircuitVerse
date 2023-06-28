require "spec_helper"

describe SimplePoParser::Parser do
  let (:po_header) { File.read(File.expand_path("fixtures/header.po", __dir__))}
  let(:po_complex_message) { File.read(File.expand_path("fixtures/complex_entry.po", __dir__))}
  let(:po_simple_message) { File.read(File.expand_path("fixtures/simple_entry.po", __dir__))}
  let(:po_multiline_message) { File.read(File.expand_path("fixtures/multiline.po", __dir__))}

  it "parses the PO header" do
    expected_result = {
      :translator_comment => ["PO Header entry", ""],
      :flag => "fuzzy",
      :msgid => "",
      :msgstr => ["", "Project-Id-Version: simple_po_parser 1\\n", "Report-Msgid-Bugs-To: me\\n"]
    }
    expect(SimplePoParser::Parser.new.parse(po_header)).to eq(expected_result)
  end

  it "parses the simple entry as expected" do
    expected_result = {
      :translator_comment => "translator-comment",
      :extracted_comment => "extract",
      :reference => "reference1",
      :msgctxt => "Context",
      :msgid => "msgid",
      :msgstr => "translated"
    }
    expect(SimplePoParser::Parser.new.parse(po_simple_message)).to eq(expected_result)
  end

  it "parses the multiline entry as expected" do
    expected_result = {
      :msgid => ["", "multiline string ", "with empty first line ", "and trailing spaces"],
      :msgstr => ["multiline string", "with non-empty first line", "and no trailing spaces"],
      :previous_msgid => ["multiline\\n", "previous messageid", "with non-empty first line"],
    }
    expect(SimplePoParser::Parser.new.parse(po_multiline_message)).to eq(expected_result)
  end

  it "parses the complex entry as expected" do
    expected_result = {
      :translator_comment => ["translator-comment", ""],
      :extracted_comment => "extract",
      :reference => ["reference1", "reference2"],
      :flag => "flag",
      :previous_msgctxt => "previous context",
      :previous_msgid => ["", "multiline\\n", "previous messageid"],
      :previous_msgid_plural => "previous msgid_plural",
      :msgctxt => "Context",
      :msgid => "msgid",
      :msgid_plural => ["", "multiline msgid_plural\\n", ""],
      "msgstr[0]" => "msgstr 0",
      "msgstr[1]" => ["", "msgstr 1 multiline 1\\n", "msgstr 1 line 2\\n"],
      "msgstr[2]" => "msgstr 2"
    }
    expect(SimplePoParser::Parser.new.parse(po_complex_message)).to eq(expected_result)
  end

  context "Errors" do
    it "errors cascade to ParserError" do
      message = "invalid message"
      expect{ SimplePoParser::Parser.new.parse(message) }.to raise_error(SimplePoParser::ParserError)
    end

    it "raises an error if there is no msgid" do
      message = "# comment\nmsgctxt \"ctxt\"\nmsgstr \"translation\""
      expect{ SimplePoParser::Parser.new.parse(message) }.
        to raise_error(SimplePoParser::ParserError, /Message without msgid is not allowed/)
    end

    it "raises an error if there is no msgstr in singular message" do
      message = "# comment\nmsgctxt \"ctxt\"\nmsgid \"msg\""
      expect{ SimplePoParser::Parser.new.parse(message) }.
        to raise_error(SimplePoParser::ParserError,
        /Singular message without msgstr is not allowed/)
    end

    it "raises an error if there is no msgstr[0] in plural message" do
      message = "# comment\nmsgid \"id\"\nmsgid_plural \"msg plural\""
      expect{ SimplePoParser::Parser.new.parse(message) }.
        to raise_error(SimplePoParser::ParserError,
        /Plural message without msgstr\[0\] is not allowed/)

      message = "# comment\nmsgid \"id\"\nmsgid_plural \"msg plural\"\nmsgstr[1] \"plural trans\""
      expect{ SimplePoParser::Parser.new.parse(message) }.
        to raise_error(SimplePoParser::ParserError,
        /Bad 'msgstr\[index\]' index/)
    end

    context "comments" do
      it "raises an error on unknown comment types" do
        message = "#- no such comment type"
        expect{ SimplePoParser::Parser.new.parse(message) }.
          to raise_error(SimplePoParser::ParserError, /Unknown comment type/)
      end

      it "raises an error on unknown previous comment types" do
        message = "#| msgstr \"no such comment type\""
        expect{ SimplePoParser::Parser.new.parse(message) }.
          to raise_error(SimplePoParser::ParserError, /Previous comment type .*? unknown/)
        message = "#| bla "
        expect{ SimplePoParser::Parser.new.parse(message) }.
          to raise_error(SimplePoParser::ParserError, /Previous comments must start with '#| msg'/)
      end

      it "raises an error if any lines are not marked obsolete after the first obsolete line" do
        message = "# comment\n#~msgid \"hi\"\nmsgstr \"should be obsolete\""
        expect{ SimplePoParser::Parser.new.parse(message) }.
          to raise_error(SimplePoParser::ParserError,
           /All lines must be obsolete after the first obsolete line, but got/)
      end

      it "raises an error if previous comments are not marked obsolete in obsolete entries" do
        message = "# comment\n#| msgid \"hi\"\n#~msgid \"hi\"\n#~msgstr \"should be obsolete\""
        expect{ SimplePoParser::Parser.new.parse(message) }.
         to raise_error(SimplePoParser::ParserError,
         /Previous comment entries need to be marked obsolete too in obsolete message entries/)
         message = "# comment\n#| msgctxt \"hi\"\n#~msgid \"hi\"\n#~msgstr \"should be obsolete\""
         expect{ SimplePoParser::Parser.new.parse(message) }.
          to raise_error(SimplePoParser::ParserError,
          /Previous comment entries need to be marked obsolete too in obsolete message entries/)
      end
    end

    context "message_line" do
      it "raises an error if a message_line does not start with a double quote" do
        message = "msgid No starting double quote\""
        expect{ SimplePoParser::Parser.new.parse(message) }.
         to raise_error(SimplePoParser::ParserError,
         /A message text needs to start with the double quote character/)
      end

      it "raises an error if a message_line does not end with a double quote" do
        message = "msgid \"No ending double quote"
        expect{ SimplePoParser::Parser.new.parse(message) }.
         to raise_error(SimplePoParser::ParserError,
         /The message text .*? must be finished with the double quote character/)
      end

      it "raises an error if there is anything but whitespace after the ending double quote" do
        message = "msgid \"text\"        this shouldn't be here"
        expect{ SimplePoParser::Parser.new.parse(message) }.
         to raise_error(SimplePoParser::ParserError,
         /There should be only whitespace until the end of line after the double quote character/)
      end
    end

  end

end
