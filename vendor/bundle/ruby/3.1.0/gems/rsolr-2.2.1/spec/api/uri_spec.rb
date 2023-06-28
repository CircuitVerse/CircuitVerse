require 'spec_helper'

RSpec.describe RSolr::Uri do
  
  let(:uri) { RSolr::Uri }

  context '.params_to_solr' do
    it "converts Hash to Solr query string w/o a starting ?" do
      hash = {:q => "gold", :fq => ["mode:one", "level:2"]}
      query = uri.params_to_solr hash
      expect(query[0]).not_to eq(??)
      [/q=gold/, /fq=mode%3Aone/, /fq=level%3A2/].each do |p|
        expect(query).to match p
      end
      expect(query.split('&').size).to eq(3)
    end
    it 'should URL escape &' do
      expect(uri.params_to_solr(:fq => "&")).to eq('fq=%26')
    end

    it 'should convert spaces to +' do
      expect(uri.params_to_solr(:fq => "me and you")).to eq('fq=me+and+you')
    end

    it 'should URL escape complex queries, part 1' do
      my_params = {'fq' => '{!raw f=field_name}crazy+\"field+value'}
      expected = 'fq=%7B%21raw+f%3Dfield_name%7Dcrazy%2B%5C%22field%2Bvalue'
      expect(uri.params_to_solr(my_params)).to eq(expected)
    end

    it 'should URL escape complex queries, part 2' do
      my_params = {'q' => '+popularity:[10 TO *] +section:0'}
      expected = 'q=%2Bpopularity%3A%5B10+TO+*%5D+%2Bsection%3A0'
      expect(uri.params_to_solr(my_params)).to eq(expected)
    end
  end
end