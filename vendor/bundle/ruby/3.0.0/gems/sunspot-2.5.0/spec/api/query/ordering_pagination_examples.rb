shared_examples_for 'sortable query' do
  it 'paginates using default per_page when page not provided' do
    search
    expect(connection).to have_last_search_with(:rows => 30)
  end

  it 'paginates using default per_page when page provided' do
    search do
      paginate :page => 2
    end
    expect(connection).to have_last_search_with(:rows => 30, :start => 30)
  end

  it 'paginates using provided per_page' do
    search do
      paginate :page => 4, :per_page => 15
    end
    expect(connection).to have_last_search_with(:rows => 15, :start => 45)
  end

  it 'defaults to page 1 if no :page argument given' do
    search do
      paginate :per_page => 15
    end
    expect(connection).to have_last_search_with(:rows => 15, :start => 0)
  end

  it 'paginates with an offset' do
    search do
      paginate :per_page => 15, :offset => 3
    end
    expect(connection).to have_last_search_with(:rows => 15, :start => 3)
  end

  it 'paginates with an offset as a string' do
    search do
      paginate :per_page => 15, :offset => '3'
    end
    expect(connection).to have_last_search_with(:rows => 15, :start => 3)
  end

  it 'paginates from string argument' do
    search do
      paginate :page => '3', :per_page => '15'
    end
    expect(connection).to have_last_search_with(:rows => 15, :start => 30)
  end

  it 'paginates with initial cursor' do
    search do
      paginate :cursor => '*', :per_page => 15
    end
    expect(connection).to have_last_search_with(:rows => 15, :cursorMark => '*')
  end

  it 'paginates with given cursor' do
    search do
      paginate :cursor => 'AoIIP4AAACxQcm9maWxlIDEwMTk='
    end
    expect(connection).to have_last_search_with(:cursorMark => 'AoIIP4AAACxQcm9maWxlIDEwMTk=')
  end

  it 'orders by a single field' do
    search do
      order_by :average_rating, :desc
    end
    expect(connection).to have_last_search_with(:sort => 'average_rating_ft desc')
  end

  it 'orders by multiple fields' do
    search do
      order_by :average_rating, :desc
      order_by :sort_title, :asc
    end
    expect(connection).to have_last_search_with(:sort => 'average_rating_ft desc, sort_title_s asc')
  end

  it 'orders by random' do
    search do
      order_by :random
    end
    expect(connection.searches.last[:sort]).to match(/^random_\d+ asc$/)
  end

  it 'orders by random with declared direction' do
    search do
      order_by :random, :desc
    end
    expect(connection.searches.last[:sort]).to match(/^random_\d+ desc$/)
  end

  it 'orders by random with provided seed value' do
    search do
      order_by :random, :seed => 9001
    end
    expect(connection.searches.last[:sort]).to match(/^random_9001 asc$/)
  end

  it 'orders by random with provided seed value and direction' do
    search do
      order_by :random, :seed => 12345, :direction => :desc
    end
    expect(connection.searches.last[:sort]).to match(/^random_12345 desc$/)
  end

  it 'orders by score' do
    search do
      order_by :score, :desc
    end
    expect(connection).to have_last_search_with(:sort => 'score desc')
  end

  it 'orders by geodist' do
    search do
      order_by_geodist :coordinates_new, 32, -68, :desc
    end
    expect(connection).to have_last_search_with(:sort => 'geodist(coordinates_new_ll,32,-68) desc')
  end

  it 'throws an ArgumentError if a bogus order direction is given' do
    expect do
      search do
        order_by :sort_title, :sideways
      end
    end.to raise_error(ArgumentError)
  end

  it 'throws an UnrecognizedFieldError if :distance is given for sort' do
    expect do
      search do
        order_by :distance, :asc
      end
    end.to raise_error(Sunspot::UnrecognizedFieldError)
  end

  it 'does not allow ordering by multiple-value fields' do
    expect do
      search do
        order_by :category_ids
      end
    end.to raise_error(ArgumentError)
  end

  it 'raises ArgumentError if bogus argument given to paginate' do
    expect do
      search do
        paginate :page => 4, :ugly => :puppy
      end
    end.to raise_error(ArgumentError)
  end
end
