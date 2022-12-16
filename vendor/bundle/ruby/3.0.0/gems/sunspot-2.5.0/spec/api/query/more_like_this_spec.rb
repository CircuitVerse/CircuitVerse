require File.expand_path('spec_helper', File.dirname(__FILE__))

describe 'more_like_this' do
  before :each do
    connection.expected_handler = :mlt
  end

  it_should_behave_like "scoped query"
  it_should_behave_like "facetable query"
  it_should_behave_like "query with advanced manipulation"
  it_should_behave_like "query with connective scope"
  it_should_behave_like "query with dynamic field support"
  it_should_behave_like "sortable query"
  it_should_behave_like "query with text field scoping"

  it 'should query passed in object' do
    p = Post.new
    session.more_like_this(p)
    expect(connection).to have_last_search_with(:q => "id:Post\\ #{p.id}")
  end

  it 'should use more_like_this fields if no fields specified' do
    session.more_like_this(Post.new)
    expect(connection.searches.last[:"mlt.fl"].split(',').sort).to eq(%w(body_textsv tags_textv))
  end

  it 'should use more_like_this fields if specified' do
    session.more_like_this(Post.new) do
      fields :body
    end
    expect(connection).to have_last_search_with(:"mlt.fl" => "body_textsv")
  end

  it 'assigns boosts to fields when specified' do
    session.more_like_this(Post.new) do
      fields :body, :tags => 8
    end
    expect(connection.searches.last[:"mlt.fl"].split(',').sort).to eq(%w(body_textsv tags_textv))
    expect(connection).to have_last_search_with(:"mlt.qf" => "tags_textv^8")
  end

  it 'doesn\'t assign boosts to fields when not specified' do
    session.more_like_this(Post.new) do
      fields :body
    end
    expect(connection).not_to have_last_search_with(:qf)
  end

  it 'should raise ArgumentError if a field is not setup for more_like_this' do
    expect do
      session.more_like_this(Post.new) do
        fields :title
      end
    end.to raise_error(ArgumentError)
  end

  it 'should accept options' do
    session.more_like_this(Post.new) do
      minimum_term_frequency 1
      minimum_document_frequency 2
      minimum_word_length 3
      maximum_word_length 4
      maximum_query_terms 5
      boost_by_relevance false
    end
    expect(connection).to have_last_search_with(:"mlt.mintf" => 1)
    expect(connection).to have_last_search_with(:"mlt.mindf" => 2)
    expect(connection).to have_last_search_with(:"mlt.minwl" => 3)
    expect(connection).to have_last_search_with(:"mlt.maxwl" => 4)
    expect(connection).to have_last_search_with(:"mlt.maxqt" => 5)
    expect(connection).to have_last_search_with(:"mlt.boost" => false)
  end

  it 'should accept short options' do
    session.more_like_this(Post.new) do
      mintf 1
      mindf 2
      minwl 3
      maxwl 4
      maxqt 5
      boost true
    end
    expect(connection).to have_last_search_with(:"mlt.mintf" => 1)
    expect(connection).to have_last_search_with(:"mlt.mindf" => 2)
    expect(connection).to have_last_search_with(:"mlt.minwl" => 3)
    expect(connection).to have_last_search_with(:"mlt.maxwl" => 4)
    expect(connection).to have_last_search_with(:"mlt.maxqt" => 5)
    expect(connection).to have_last_search_with(:"mlt.boost" => true)
  end

  it 'paginates using default per_page when page not provided' do
    session.more_like_this(Post.new)
    expect(connection).to have_last_search_with(:rows => 30)
  end

  it 'paginates using default per_page when page provided' do
    session.more_like_this(Post.new) do
      paginate :page => 2
    end
    expect(connection).to have_last_search_with(:rows => 30, :start => 30)
  end

  it 'paginates using provided per_page' do
    session.more_like_this(Post.new) do
      paginate :page => 4, :per_page => 15
    end
    expect(connection).to have_last_search_with(:rows => 15, :start => 45)
  end

  it 'defaults to page 1 if no :page argument given' do
    session.more_like_this(Post.new) do
      paginate :per_page => 15
    end
    expect(connection).to have_last_search_with(:rows => 15, :start => 0)
  end

  it 'paginates from string argument' do
    session.more_like_this(Post.new) do
      paginate :page => '3', :per_page => '15'
    end
    expect(connection).to have_last_search_with(:rows => 15, :start => 30)
  end

  it "should send query to solr with adjusted parameters (keyword example)" do
    session.more_like_this(Post.new) do
      adjust_solr_params do |params|
        params[:q]    = 'new search'
        params[:some] = 'param'
      end
    end
    expect(connection).to have_last_search_with(:q    => 'new search')
    expect(connection).to have_last_search_with(:some => 'param')
  end

  it "should send query to solr with adjusted parameters in multiple blocks" do
    session.more_like_this(Post.new) do
      adjust_solr_params do |params|
        params[:q]    = 'new search'
      end
      adjust_solr_params do |params|
        params[:some] = 'param'
      end
    end
    expect(connection).to have_last_search_with(:q    => 'new search')
    expect(connection).to have_last_search_with(:some => 'param')
  end

  private

  def search(*args, &block)
    session.more_like_this(Post.new, *args, &block)
  end
end
