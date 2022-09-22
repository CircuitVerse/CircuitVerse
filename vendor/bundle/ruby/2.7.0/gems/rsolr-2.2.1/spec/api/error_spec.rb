require 'spec_helper'

RSpec.describe RSolr::Error do
  def generate_error_with_backtrace(request, response)
    raise RSolr::Error::Http.new request, response
  rescue RSolr::Error::Http => exception
    exception
  end
  let (:response_lines) { (1..15).to_a.map { |i| "line #{i}" } }
  let(:request)  { double :[] => "mocked" }
  let(:response_body) { response_lines.join("\n") }
  let(:response) {{
    :body   => response_body,
    :status => 400
  }}
  subject { generate_error_with_backtrace(request, response).to_s }

  context "when the response body is wrapped in a <pre> element" do
    let(:response_body) { "<pre>" + response_lines.join("\n") + "</pre>" }

    it "only shows the first eleven lines of the response" do
      expect(subject).to match(/line 1\n.+line 11\n\n/m)
    end

    context "when the response is one line long" do
      let(:response_body) { "<pre>failed</pre>" }
      it { should match(/Error: failed/) }
    end
  end

  context "when the response body is not wrapped in a <pre> element" do

    it "only shows the first eleven lines of the response" do
      expect(subject).to match(/line 1\n.+line 11\n\n/m)
    end

    context "when the response is one line long" do
      let(:response_body) { 'failed' }
      it { should match(/Error: failed/) }
    end
    context "when the response body contains a msg key" do
      let(:msg) { "'org.apache.solr.search.SyntaxError: Cannot parse \\':false\\': Encountered \" \":\" \": \"\" at line 1, column 0.'" }
      let(:response_body) { (response_lines << "'error'=>{'msg'=> #{msg}").join("\n") }
      it { should include msg }
    end
  end
end
