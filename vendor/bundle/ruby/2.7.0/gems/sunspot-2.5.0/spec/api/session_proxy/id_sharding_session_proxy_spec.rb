require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Sunspot::SessionProxy::ShardingSessionProxy do
  before do
    search_session = Sunspot::Session.new
    @sessions = Array.new(2) { Sunspot::Session.new }
    @proxy = Sunspot::SessionProxy::IdShardingSessionProxy.new(search_session, @sessions)
  end

  [:index, :index!, :remove, :remove!].each do |method|
    it "should delegate #{method} to appropriate shard" do
      posts = [Post.new(:id => 2), Post.new(:id => 1)]
      expect(@proxy.sessions[0]).to receive(method).with([posts[0]])
      expect(@proxy.sessions[1]).to receive(method).with([posts[1]])
      @proxy.send(method, posts[0])
      @proxy.send(method, posts[1])
    end
  end

  [:remove_by_id, :remove_by_id!].each do |method|
    it "should delegate #{method} to appropriate session" do
      expect(@proxy.sessions[1]).to receive(method).with(Post, [3])
      expect(@proxy.sessions[0]).to receive(method).with(Post, [2])
      expect(@proxy.sessions[1]).to receive(method).with(Post, [1])
      @proxy.send(method, Post, 1)
      @proxy.send(method, Post, 2)
      @proxy.send(method, Post, 3)
    end
    it "should delegate #{method} to appropriate session given splatted index ids" do
      expect(@proxy.sessions[0]).to receive(method).with(Post, [2])
      expect(@proxy.sessions[1]).to receive(method).with(Post, [1, 3])
      @proxy.send(method, Post, 1, 2, 3)
    end
    it "should delegate #{method} to appropriate session given array of index ids" do
      expect(@proxy.sessions[0]).to receive(method).with(Post, [2])
      expect(@proxy.sessions[1]).to receive(method).with(Post, [1, 3])
      @proxy.send(method, Post, [1, 2, 3])
    end
  end

  it_should_behave_like 'session proxy'
end
