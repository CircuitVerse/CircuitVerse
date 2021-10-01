require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Sunspot::SessionProxy::ShardingSessionProxy do
  
  FakeException = Class.new(StandardError)
  SUPPORTED_METHODS = Sunspot::SessionProxy::SilentFailSessionProxy::SUPPORTED_METHODS

  before do
    @search_session = double(Sunspot::Session.new)
    @proxy = Sunspot::SessionProxy::SilentFailSessionProxy.new(@search_session)
  end
  
  it "should call rescued_exception when an exception is caught" do
    SUPPORTED_METHODS.each do |method|
      e = FakeException.new(method)
      allow(@search_session).to receive(method).and_raise(e)
      expect(@proxy).to receive(:rescued_exception).with(method, e)
      @proxy.send(method)
    end
  end
  
  it_should_behave_like 'session proxy'
  
end
