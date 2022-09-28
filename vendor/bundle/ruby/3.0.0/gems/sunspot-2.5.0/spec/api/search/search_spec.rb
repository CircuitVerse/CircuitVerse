require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Sunspot::Search do
  it 'should allow access to the data accessor' do
    stub_results(posts = Post.new)
    search = session.search Post do
      data_accessor_for(Post).custom_title = 'custom title'
    end
    expect(search.results.first.title).to eq('custom title')
  end
  
  it 'should re-execute search' do
    post_1, post_2 = Post.new, Post.new
    
    stub_results(post_1)
    search = session.search Post
    expect(search.results).to eq([post_1])
    
    stub_results(post_2)
    search.execute!
    expect(search.results).to eq([post_2])
  end
end
