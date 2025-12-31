
require 'rails_helper'
require 'rack/test'

RSpec.describe Utf8Sanitizer do
  include Rack::Test::Methods

  let(:app) do
    Rack::Builder.new do
      use Utf8Sanitizer
      run lambda { |env| [200, {}, ["OK"]] }
    end
  end

  it "sanitizes UTF-16LE query string" do
    # Create the problematic UTF-16LE string
    bad_param = "foo".encode(Encoding::UTF_16LE)
    
    # We need to simulate the environment Rack would set up.
    # Rack::Test passes arguments to `call`.
    
    # We can invoke the middleware directly to be more precise about the env.
    sanitizer = Utf8Sanitizer.new(lambda { |env| [200, {}, ["OK"]] })
    
    env = {
        "QUERY_STRING" => "user[name]=foo".encode(Encoding::UTF_16LE),
        "REQUEST_URI" => "/test?user[name]=foo".encode(Encoding::UTF_16LE)
    }
    
    expect { sanitizer.call(env) }.not_to raise_error
    
    expect(env["QUERY_STRING"].encoding).to eq(Encoding::UTF_8)
    expect(env["REQUEST_URI"].encoding).to eq(Encoding::UTF_8)
    expect(env["QUERY_STRING"]).to eq("user[name]=foo")
  end

  it "handles valid UTF-8 gracefully" do
     sanitizer = Utf8Sanitizer.new(lambda { |env| [200, {}, ["OK"]] })
     env = {
        "QUERY_STRING" => "user[name]=foo",
        "REQUEST_URI" => "/test?user[name]=foo"
     }
     
     sanitizer.call(env)
     expect(env["QUERY_STRING"]).to eq("user[name]=foo")
     expect(env["QUERY_STRING"].encoding).to eq(Encoding::UTF_8)
  end
  
  it "replaces invalid characters" do
      sanitizer = Utf8Sanitizer.new(lambda { |env| [200, {}, ["OK"]] })
      
      # invalid sequence in UTF-8
      bad_string = "foo\xFFbar".force_encoding("UTF-8") 
      
      env = { "QUERY_STRING" => bad_string }
      sanitizer.call(env)
      
      expect(env["QUERY_STRING"]).to eq("foobar") # \xFF is replaced by empty str based on my implementation? 
      # My implementation: encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '')
      # So yes, it should remove it.
  end
end
