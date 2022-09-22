require File.expand_path('spec_helper', File.dirname(__FILE__))

describe 'document removal', :type => :indexer do
  it 'removes an object from the index' do
    session.remove(post)
    expect(connection).to have_delete("Post #{post.id}")
  end

  it 'removes an object by type and id' do
    session.remove_by_id(Post, 1)
    expect(connection).to have_delete('Post 1')
  end

  it 'removes an object by type and ids' do
    session.remove_by_id(Post, 1, 2)
    expect(connection).to have_delete('Post 1', 'Post 2')
  end

  it 'removes an object by type and ids array' do
    session.remove_by_id(Post, [1, 2])
    expect(connection).to have_delete('Post 1', 'Post 2')
  end

  it 'removes an object by type and ids and immediately commits' do
    expect(connection).to receive(:delete_by_id).with(['Post 1', 'Post 2', 'Post 3']).ordered
    expect(connection).to receive(:commit).ordered
    session.remove_by_id!(Post, 1, 2, 3)
  end

  it 'removes an object from the index and immediately commits' do
    expect(connection).to receive(:delete_by_id).ordered
    expect(connection).to receive(:commit).ordered
    session.remove!(post)
  end

  it 'removes everything from the index' do
    session.remove_all
    expect(connection).to have_delete_by_query("*:*")
  end

  it 'removes everything from the index and immediately commits' do
    expect(connection).to receive(:delete_by_query).ordered
    expect(connection).to receive(:commit).ordered
    session.remove_all!
  end

  it 'removes everything of a given class from the index' do
    session.remove_all(Post)
    expect(connection).to have_delete_by_query("type:Post")
  end

  it 'correctly escapes namespaced classes when removing everything from the index' do
    expect(connection).to receive(:delete_by_query).with('type:Namespaced\:\:Comment')
    session.remove_all(Namespaced::Comment)
  end

  it 'should remove by query' do
    session.remove(Post) do
      with(:title, 'monkeys')
    end
    expect(connection).to have_delete_by_query("(type:Post AND title_ss:monkeys)")
  end
end
