require 'spec_helper'
require 'solr_wrapper'

RSpec.describe "Solr basic_configs" do
  SOLR_INSTANCE =  SolrWrapper.default_instance({})
  before(:all) { SOLR_INSTANCE.start }
  after(:all) { SOLR_INSTANCE.stop }

  context "basic configs" do
    subject { RSolr.connect url: "http://localhost:#{SOLR_INSTANCE.port}/solr/basic_configs/"}
    around(:each) do |example|
      SOLR_INSTANCE.with_collection(name: "basic_configs", dir: File.join(FIXTURES_DIR, "basic_configs")) do |coll|
        example.run
      end
    end
    describe "HEAD admin/ping" do
      it "should not raise an exception" do
        expect { subject.head('admin/ping') }.not_to raise_error
      end

      it "should not have a body" do
        expect(subject.head('admin/ping')).to be_kind_of RSolr::HashWithResponse
      end
    end
  end

  context "error handling" do
    subject { RSolr.connect url: "http://localhost:65432/solr/basic_configs/"}

    it "wraps connection errors" do
      expect { subject.head('admin/ping') }.to raise_error RSolr::Error::ConnectionRefused
    end
  end
end
