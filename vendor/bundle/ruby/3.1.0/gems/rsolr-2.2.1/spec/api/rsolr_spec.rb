require 'spec_helper'

RSpec.describe RSolr do
  
  it "has a version that can be read via #version or VERSION" do
    expect(RSolr.version).to eq(RSolr::VERSION)
  end

  context "connect" do
    it "should return a RSolr::Client instance" do
      expect(RSolr.connect).to be_a(RSolr::Client)
    end
  end
  
  context '.solr_escape' do
    it "adds backslash to Solr query syntax chars" do
      # per http://lucene.apache.org/core/4_0_0/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#Escaping_Special_Characters
      special_chars = [ "+", "-", "&", "|", "!", "(", ")", "{", "}", "[", "]", "^", '"', "~", "*", "?", ":", "\\", "/" ]
      escaped_str = RSolr.solr_escape("aa#{special_chars.join('aa')}aa")
      special_chars.each { |c|
        # note that the ruby code sending the query to Solr will un-escape the backslashes
        # so the result sent to Solr is ultimately a single backslash in front of the particular character 
        expect(escaped_str).to match "\\#{c}"
      }
    end
    it "leaves other chars alone" do
      str = "nothing to see here; let's move along people."
      expect(RSolr.solr_escape(str)).to eq str
    end
  end
end
