require 'spec_helper'

RSpec.describe RSolr::Client do
  context "build_paginated_request" do
    it "should create the proper solr params and query string" do
      c = RSolr::Client.new(nil, {})#.extend(RSolr::Pagination::Client)
      r = c.build_paginated_request 3, 25, "select", {:params => {:q => "test"}}
      #r[:page].should == 3
      #r[:per_page].should == 25
      expect(r[:params]["start"]).to eq(50)
      expect(r[:params]["rows"]).to eq(25)
      expect(r[:uri].query).to match(/rows=25/)
      expect(r[:uri].query).to match(/start=50/)
    end
  end
  context "paginate" do
    it "should build a paginated request context and call execute" do
      c = RSolr::Client.new(nil, {})#.extend(RSolr::Pagination::Client)
      expect(c).to receive(:execute).with(hash_including({
        #:page => 1,
        #:per_page => 10,
        :params => {
          "rows" => 10,
          "start" => 0,
          :wt => :json
        }
      }))
      c.paginate 1, 10, "select"
    end
  end
end