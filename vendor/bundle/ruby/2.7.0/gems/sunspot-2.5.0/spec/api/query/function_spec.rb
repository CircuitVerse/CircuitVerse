require File.expand_path('spec_helper', File.dirname(__FILE__))

describe 'function query' do
  it "should send query to solr with boost function" do
    session.search Post do
      keywords('pizza') do
        boost(function { :average_rating })
      end
    end
    expect(connection).to have_last_search_including(:bf, 'average_rating_ft')
  end

  it "should send query to solr with boost function and boost amount" do
    session.search Post do
      keywords('pizza') do
        boost(function { :average_rating }^5)
      end
    end
    expect(connection).to have_last_search_including(:bf, 'average_rating_ft^5')
  end

  it "should handle boost function with constant float" do
    session.search Post do
      keywords('pizza') do
        boost(function { 10.5 })
      end
    end
    expect(connection).to have_last_search_including(:bf, '10.5')
  end

  it "should handle boost function with constant float and boost amount" do
    session.search Post do
      keywords('pizza') do
        boost(function { 10.5 }^5)
      end
    end
    expect(connection).to have_last_search_including(:bf, '10.5^5')
  end

  it "should handle boost function with time literal" do
    session.search Post do
      keywords('pizza') do
        boost(function { Time.parse('2010-03-25 14:13:00 EDT') })
      end
    end
    expect(connection).to have_last_search_including(:bf, '2010-03-25T18:13:00Z')
  end
 
  it "should handle arbitrary functions in a function query block" do
    session.search Post do
      keywords('pizza') do
        boost(function { product(:average_rating, 10) })
      end
    end
    expect(connection).to have_last_search_including(:bf, 'product(average_rating_ft,10)')
  end

  it "should handle the sub function in a function query block" do
    session.search Post do
      keywords('pizza') do
        boost(function { sub(:average_rating, 10) })
      end
    end
    expect(connection).to have_last_search_including(:bf, 'sub(average_rating_ft,10)')
  end

  it "should handle boost amounts on function query block" do
    session.search Post do
      keywords('pizza') do
        boost(function { sub(:average_rating, 10)^5 })
      end
    end
    expect(connection).to have_last_search_including(:bf, 'sub(average_rating_ft,10)^5')
  end
 
  it "should handle nested functions in a function query block" do
    session.search Post do
      keywords('pizza') do
        boost(function { product(:average_rating, sum(:average_rating, 20)) })
      end
    end
    expect(connection).to have_last_search_including(:bf, 'product(average_rating_ft,sum(average_rating_ft,20))')
  end

  # TODO SOLR 1.5
  it "should raise ArgumentError if string literal passed" do
    expect do
      session.search Post do
        keywords('pizza') do
          boost(function { "hello world" })
        end
      end
    end.to raise_error(ArgumentError)
  end

  it "should raise UnrecognizedFieldError if bogus field name passed" do
    expect do
      session.search Post do
        keywords('pizza') do
          boost(function { :bogus })
        end
      end
    end.to raise_error(Sunspot::UnrecognizedFieldError)
  end

  it "should send query to solr with multiplicative boost function" do
    session.search Post do
      keywords('pizza') do
        multiplicative_boost(function { :average_rating })
      end
    end
    expect(connection).to have_last_search_including(:boost, 'average_rating_ft')
  end

  it "should send query to solr with multiplicative boost function and boost amount" do
    session.search Post do
      keywords('pizza') do
        multiplicative_boost(function { :average_rating }^5)
      end
    end
    expect(connection).to have_last_search_including(:boost, 'average_rating_ft^5')
  end

  it "should handle multiplicative boost function with constant float" do
    session.search Post do
      keywords('pizza') do
        multiplicative_boost(function { 10.5 })
      end
    end
    expect(connection).to have_last_search_including(:boost, '10.5')
  end

  it "should handle multiplicative boost function with constant float and boost amount" do
    session.search Post do
      keywords('pizza') do
        multiplicative_boost(function { 10.5 }^5)
      end
    end
    expect(connection).to have_last_search_including(:boost, '10.5^5')
  end

  it "should handle multiplicative boost function with time literal" do
    session.search Post do
      keywords('pizza') do
        multiplicative_boost(function { Time.parse('2010-03-25 14:13:00 EDT') })
      end
    end
    expect(connection).to have_last_search_including(:boost, '2010-03-25T18:13:00Z')
  end
 
  it "should handle arbitrary functions in a function query block" do
    session.search Post do
      keywords('pizza') do
        multiplicative_boost(function { product(:average_rating, 10) })
      end
    end
    expect(connection).to have_last_search_including(:boost, 'product(average_rating_ft,10)')
  end

  it "should handle the sub function in a multiplicative boost function query block" do
    session.search Post do
      keywords('pizza') do
        multiplicative_boost(function { sub(:average_rating, 10) })
      end
    end
    expect(connection).to have_last_search_including(:boost, 'sub(average_rating_ft,10)')
  end

  it "should handle boost amounts on multiplicative boost function query block" do
    session.search Post do
      keywords('pizza') do
        multiplicative_boost(function { sub(:average_rating, 10)^5 })
      end
    end
    expect(connection).to have_last_search_including(:boost, 'sub(average_rating_ft,10)^5')
  end
 
  it "should handle nested functions in a multiplicative boost function query block" do
    session.search Post do
      keywords('pizza') do
        multiplicative_boost(function { product(:average_rating, sum(:average_rating, 20)) })
      end
    end
    expect(connection).to have_last_search_including(:boost, 'product(average_rating_ft,sum(average_rating_ft,20))')
  end

  # TODO SOLR 1.5
  it "should raise ArgumentError if string literal passed to multiplicative boost" do
    expect do
      session.search Post do
        keywords('pizza') do
          multiplicative_boost(function { "hello world" })
        end
      end
    end.to raise_error(ArgumentError)
  end

  it "should raise UnrecognizedFieldError if bogus field name passed to multiplicative boost" do
    expect do
      session.search Post do
        keywords('pizza') do
          multiplicative_boost(function { :bogus })
        end
      end
    end.to raise_error(Sunspot::UnrecognizedFieldError)
  end

end

