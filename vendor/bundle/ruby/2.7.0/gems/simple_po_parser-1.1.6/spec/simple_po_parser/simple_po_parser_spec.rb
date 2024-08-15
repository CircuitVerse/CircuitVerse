require "spec_helper"

describe SimplePoParser do
  let(:po_file) { Pathname.new('spec/simple_po_parser/fixtures/complete_file.po').realpath }
  let(:crlf_file) { Pathname.new('spec/simple_po_parser/fixtures/crlf_encoded.po').realpath }
  let(:non_ascii_file) { Pathname.new('spec/simple_po_parser/fixtures/non_ascii_file.po').realpath }
  let(:po_complex_message) { File.read(File.expand_path("fixtures/complex_entry.po", __dir__))}

  it "parses a po file" do
    expect(SimplePoParser.parse(po_file)).to be_a_kind_of Array
  end
  it "parses crlf encoded files" do
    expect(SimplePoParser.parse(crlf_file)).to be_a_kind_of Array
  end

  it "parses a non ascii po file" do
    expect(SimplePoParser.parse(non_ascii_file)).to be_a_kind_of Array
  end

  it "parses a single message" do
    expect(SimplePoParser.parse_message(po_complex_message)).to be_a_kind_of Hash
  end

end
