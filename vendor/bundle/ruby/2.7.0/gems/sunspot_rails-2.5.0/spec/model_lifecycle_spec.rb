require File.expand_path('spec_helper', File.dirname(__FILE__))

describe 'searchable with lifecycle' do
  describe 'on create' do
    before :each do
      @post = PostWithAuto.create
      Sunspot.commit
    end

    it 'should automatically index' do
      expect(PostWithAuto.search.results).to eq([@post])
    end
  end

  describe 'on update' do
    before :each do
      @post = PostWithAuto.create
      @post.update_attributes(:title => 'Test 1')
      Sunspot.commit
    end

    it 'should automatically update index' do
      expect(PostWithAuto.search { with :title, 'Test 1' }.results).to eq([@post])
    end

    it "should index model if relevant attribute changed" do
      @post = PostWithAuto.create!
      @post.title = 'new title'
      expect(@post).to receive :solr_index
      @post.save!
    end

    it "should not index model if relevant attribute not changed" do
      @post = PostWithAuto.create!
      @post.updated_at = Date.tomorrow
      expect(@post).not_to receive :solr_index
      @post.save!
    end
  end

  describe 'on destroy' do
    before :each do
      @post = PostWithAuto.create
      @post.destroy
      Sunspot.commit
    end

    it 'should automatically remove it from the index' do
      expect(PostWithAuto.search_ids).to be_empty
    end
  end

  describe 'ignoring specific attributes' do
    before(:each) do
      @post = PostWithAuto.create
    end

    it "should not reindex the object on an update_at change, because it is marked as to-ignore" do
      expect(Sunspot).not_to receive(:index).with(@post)
      @post.update_attribute :updated_at, 123.seconds.from_now
    end
  end

  describe 'only paying attention to specific attributes' do
    before(:each) do
      @post = PostWithOnlySomeAttributesTriggeringReindex.create
    end

    it "should not reindex the object on an update_at change, because it is not in the whitelist" do
      expect(Sunspot).not_to receive(:index).with(@post)
      @post.update_attribute :updated_at, 123.seconds.from_now
    end

    it "should reindex the object on a title change, because it is in the whitelist" do
      expect(Sunspot).to receive(:index).with(@post)
      @post.update_attribute :title, "brand new title"
    end

  end
end

