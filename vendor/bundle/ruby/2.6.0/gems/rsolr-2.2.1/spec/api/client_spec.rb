require 'spec_helper'

RSpec.describe RSolr::Client do
  let(:connection) { nil }
  let(:url) { "http://localhost:9999/solr" }
  let(:connection_options) { { url: url, read_timeout: 42, open_timeout: 43, update_format: :xml } }

  let(:client) do
    RSolr::Client.new connection, connection_options
  end

  let(:client_with_proxy) do
    RSolr::Client.new connection, connection_options.merge(proxy: 'http://localhost:8080')
  end

  context "initialize" do
    it "should accept whatevs and set it as the @connection" do
      expect(RSolr::Client.new(:whatevs).connection).to eq(:whatevs)
    end

    it "should use :update_path from options" do
      client = RSolr::Client.new(:whatevs, { update_path: 'update_test' })
      expect(client.update_path).to eql('update_test')
    end

    it "should use 'update' for update_path by default" do
      client = RSolr::Client.new(:whatevs)
      expect(client.update_path).to eql('update')
    end

    it "should use :proxy from options" do
      client = RSolr::Client.new(:whatevs, { proxy: 'http://my.proxy/' })
      expect(client.proxy.to_s).to eql('http://my.proxy/')
    end

    it "should use 'nil' for proxy by default" do
      client = RSolr::Client.new(:whatevs)
      expect(client.proxy).to be_nil
    end

    it "should use 'false' for proxy if passed 'false'" do
      client = RSolr::Client.new(:whatevs, { proxy: false })
      expect(client.proxy).to eq(false)
    end

    context "with an non-HTTP url" do
      let(:url) { "fake://localhost:9999/solr" }

      it "raises an argument error" do
        expect { client }.to raise_error ArgumentError, "You must provide an HTTP(S) url."
      end
    end

    context "with an HTTPS url" do
      let(:url) { "https://localhost:9999/solr" }

      it "creates a connection" do
        expect(client.uri).to be_kind_of URI::HTTPS
      end
    end

  end

  context "send_and_receive" do
    it "should forward these method calls the #connection object" do
      [:get, :post, :head].each do |meth|
        expect(client).to receive(:execute).
          and_return({:status => 200, :body => "{}", :headers => {}})
        client.send_and_receive '', :method => meth, :params => {}, :data => nil, :headers => {}
      end
    end
  end

  context "post" do
    it "should pass the expected params to the connection's #execute method" do
      request_opts = {:data => "the data", :method=>:post, :headers => {"Content-Type" => "text/plain"}}
      expect(client).to receive(:execute).
        with(hash_including(request_opts)).
        and_return(
          :body => "",
          :status => 200,
          :headers => {"Content-Type"=>"text/plain"}
        )
        client.post "update", request_opts
    end
  end

  context "add" do
    it "should send xml to the connection's #post method" do
      expect(client).to receive(:execute).
        with(
          hash_including({
            :path => "update",
            :headers => {"Content-Type"=>"text/xml"},
            :method => :post,
            :data => "<xml/>"
          })
      ).
      and_return(
        :body => "",
        :status => 200,
        :headers => {"Content-Type"=>"text/xml"}
      )
      expect(client.builder).to receive(:add).
        with({:id=>1}, {:commitWith=>10}).
        and_return("<xml/>")
      client.add({:id=>1}, :add_attributes => {:commitWith=>10})
    end

    context 'when the client is configured for json updates' do
      let(:client) do
        RSolr::Client.new nil, :url => "http://localhost:9999/solr", :read_timeout => 42, :open_timeout=>43, :update_format => :json
      end
      it "should send json to the connection's #post method" do
        expect(client).to receive(:execute).
          with(hash_including({
              :path => 'update',
              :headers => {"Content-Type" => 'application/json'},
              :method => :post,
              :data => '{"hello":"this is json"}'
            })
          ).
            and_return(
              :body => "",
              :status => 200,
              :headers => {"Content-Type"=>"text/xml"}
            )
        expect(client.builder).to receive(:add).
          with({:id => 1}, {:commitWith=>10}).
            and_return('{"hello":"this is json"}')
        client.add({:id=>1}, :add_attributes => {:commitWith=>10})
      end

      it "should send json to the connection's #post method" do
        expect(client).to receive(:execute).
          with(hash_including({
              :path => 'update',
              :headers => {'Content-Type'=>'application/json'},
              :method => :post,
              :data => '{"optimise" : {}}'
            })
          ).
            and_return(
              :body => "",
              :status => 200,
              :headers => {"Content-Type"=>"text/xml"}
          )
        client.update(:data => '{"optimise" : {}}')
      end
    end
  end

  context "update" do
    it "should send data to the connection's #post method" do
      expect(client).to receive(:execute).
        with(hash_including({
            :path => "update",
            :headers => {"Content-Type"=>"text/xml"},
            :method => :post,
            :data => "<optimize/>"
          })
      ).
      and_return(
        :body => "",
        :status => 200,
        :headers => {"Content-Type"=>"text/xml"}
      )
      client.update(:data => "<optimize/>")
    end

    it "should use #update_path" do
      expect(client).to receive(:post).with('update_test', any_args)
      expect(client).to receive(:update_path).and_return('update_test')
      client.update({})
    end

    it "should use path from opts" do
      expect(client).to receive(:post).with('update_opts', any_args)
      allow(client).to receive(:update_path).and_return('update_test')
      client.update({path: 'update_opts'})
    end
  end

  context "post based helper methods:" do
    [:commit, :optimize, :rollback].each do |meth|
      it "should send a #{meth} message to the connection's #post method" do
        expect(client).to receive(:execute).
          with(hash_including({
              :path => "update",
              :headers => {"Content-Type"=>"text/xml"},
              :method => :post,
              :data => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><#{meth}/>"
            })
        ).
        and_return(
          :body => "",
          :status => 200,
          :headers => {"Content-Type"=>"text/xml"}
        )
        client.send meth
      end
    end
  end

  context "delete_by_id" do
    it "should send data to the connection's #post method" do
      expect(client).to receive(:execute).
        with(
          hash_including({
            :path => "update",
            :headers => {"Content-Type"=>"text/xml"},
            :method => :post,
            :data => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><id>1</id></delete>"
          })
      ).
      and_return(
        :body => "",
        :status => 200,
        :headers => {"Content-Type"=>"text/xml"}
      )
      client.delete_by_id 1
    end
  end

  context "delete_by_query" do
    it "should send data to the connection's #post method" do
      expect(client).to receive(:execute).
        with(
          hash_including({
            :path => "update",
            :headers => {"Content-Type"=>"text/xml"},
            :method => :post,
            :data => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><query fq=\"category:&quot;trash&quot;\"/></delete>"
          })
      ).
      and_return(
        :body => "",
        :status => 200,
        :headers => {"Content-Type"=>"text/xml"}
      )
      client.delete_by_query :fq => "category:\"trash\""
    end
  end

  context "adapt_response" do
    it 'should not try to evaluate ruby when the :qt is not :ruby' do
      body = '{"time"=>"NOW"}'
      result = client.adapt_response({:params=>{}}, {:status => 200, :body => body, :headers => {}})
      expect(result).to eq(body)
    end

    it 'should evaluate ruby responses when the :wt is :ruby' do
      body = '{"time"=>"NOW"}'
      result = client.adapt_response({:params=>{:wt=>:ruby}}, {:status => 200, :body => body, :headers => {}})
      expect(result).to eq({"time"=>"NOW"})
    end

    it 'should evaluate json responses when the :wt is :json' do
      body = '{"time": "NOW"}'
      result = client.adapt_response({:params=>{:wt=>:json}}, {:status => 200, :body => body, :headers => {}})
      if defined? JSON
        expect(result).to eq({"time"=>"NOW"})
      else
        # ruby 1.8 without the JSON gem
        expect(result).to eq('{"time": "NOW"}')
      end
    end

    it 'should return a response for a head request' do
      result = client.adapt_response({:method=>:head,:params=>{}}, {:status => 200, :body => nil, :headers => {}})
      expect(result.response[:status]).to eq 200
    end

    it "ought raise a RSolr::Error::InvalidRubyResponse when the ruby is indeed frugged, or even fruggified" do
      expect {
        client.adapt_response({:params=>{:wt => :ruby}}, {:status => 200, :body => "<woops/>", :headers => {}})
      }.to raise_error RSolr::Error::InvalidRubyResponse
    end

  end

  context "indifferent access" do
    it "should raise a RuntimeError if the #with_indifferent_access extension isn't loaded" do
      hide_const("::RSolr::HashWithIndifferentAccessWithResponse")
      hide_const("ActiveSupport::HashWithIndifferentAccess")
      body = "{'foo'=>'bar'}"
      result = client.adapt_response({:params=>{:wt=>:ruby}}, {:status => 200, :body => body, :headers => {}})
      expect { result.with_indifferent_access }.to raise_error RuntimeError
    end

    it "should provide indifferent access" do
      require 'active_support/core_ext/hash/indifferent_access'
      body = "{'foo'=>'bar'}"
      result = client.adapt_response({:params=>{:wt=>:ruby}}, {:status => 200, :body => body, :headers => {}})
      indifferent_result = result.with_indifferent_access

      expect(result).to be_a(RSolr::Response)
      expect(result['foo']).to eq('bar')
      expect(result[:foo]).to be_nil

      expect(indifferent_result).to be_a(RSolr::Response)
      expect(indifferent_result['foo']).to eq('bar')
      expect(indifferent_result[:foo]).to eq('bar')
    end
  end

  context "build_request" do
    let(:data) { 'data' }
    let(:params) { { q: 'test', fq: [0,1] } }
    let(:options) { { method: :post, params: params, data: data, headers: {} } }
    subject { client.build_request('select', options) }

    context "when params are symbols" do
      it 'should return a request context array' do
        [/fq=0/, /fq=1/, /q=test/, /wt=json/].each do |pattern|
          expect(subject[:query]).to match pattern
        end
        expect(subject[:data]).to eq("data")
        expect(subject[:headers]).to eq({})
      end
    end

    context "when params are strings" do
      let(:params) { { 'q' => 'test', 'wt' => 'json' } }
      it 'should return a request context array' do
        expect(subject[:query]).to eq 'q=test&wt=json'
        expect(subject[:data]).to eq("data")
        expect(subject[:headers]).to eq({})
      end
    end

    context "when a Hash is passed in as data" do
      let(:data) { { q: 'test', fq: [0,1] } }
      let(:options) { { method: :post, data: data, headers: {} } }

      it "sets the Content-Type header to application/x-www-form-urlencoded; charset=UTF-8" do
        expect(subject[:query]).to eq("wt=json")
        [/fq=0/, /fq=1/, /q=test/].each do |pattern|
          expect(subject[:data]).to match pattern
        end
        expect(subject[:data]).not_to match(/wt=json/)
        expect(subject[:headers]).to eq({"Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8"})
      end
    end
   
    it "should properly handle proxy configuration" do
      result = client_with_proxy.build_request('select',
        :method => :post,
        :data => {:q=>'test', :fq=>[0,1]},
        :headers => {}
      )
      expect(result[:uri].to_s).to match %r{^http://localhost:9999/solr/}
    end
  end
end
