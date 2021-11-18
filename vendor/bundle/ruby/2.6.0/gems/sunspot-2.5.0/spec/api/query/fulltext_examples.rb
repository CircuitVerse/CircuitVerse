shared_examples_for 'fulltext query' do
  it 'searches by keywords' do
    search do
      keywords 'keyword search'
    end
    expect(connection).to have_last_search_with(:q => 'keyword search')
  end

  it 'ignores keywords if empty' do
    search do
      keywords ''
    end
    expect(connection).not_to have_last_search_with(:defType => 'edismax')
  end

  it 'ignores keywords if nil' do
    search do
      keywords nil
    end
    expect(connection).not_to have_last_search_with(:defType => 'edismax')
  end

  it 'ignores keywords with only whitespace' do
    search do
      keywords "  \t"
    end
    expect(connection).not_to have_last_search_with(:defType => 'edismax')
  end

  it 'gracefully ignores keywords block if keywords ignored' do
    search do
      keywords(nil) { fields(:title) }
    end
  end

  it 'sets default query parser to dismax when keywords used' do
    search do
      keywords 'keyword search'
    end
    expect(connection).to have_last_search_with(:defType => 'edismax')
  end

  it 'searches types in filter query if keywords used' do
    search do
      keywords 'keyword search'
    end
    expect(connection).to have_last_search_with(:fq => ['type:Post'])
  end

  describe 'with multiple keyword components' do
    before :each do
      session.search Post do
        keywords 'first search', :fields => :title
        keywords 'second search'
      end
    end

    it 'puts specified keywords in subquery' do
      expect(subqueries(:q).map { |subquery| subquery[:v] }).to eq(
        ['first search', 'second search']
      )
    end

    it 'puts specified dismax parameters in subquery' do
      expect(subqueries(:q).first[:qf]).to eq('title_text')
    end

    it 'puts default dismax parameters in subquery' do
      expect(subqueries(:q).last[:qf].split(' ').sort).to(
        eq(%w(backwards_title_text body_textsv tags_textv text_array_text title_text))
      )
    end

    it 'puts field list in main query' do
      expect(connection).to have_last_search_with(:fl => '* score')
    end
  end

  it 'searches all text fields for searched class' do
    search = search do
      keywords 'keyword search'
    end
    expect(connection.searches.last[:qf].split(' ').sort).to(
      eq(%w(backwards_title_text body_textsv tags_textv text_array_text title_text))
    )
  end

  it 'searches both stored and unstored text fields' do
    search Post, Namespaced::Comment do
      keywords 'keyword search'
    end
    expect(connection.searches.last[:qf].split(' ').sort).to(
      eq(%w(author_name_text backwards_title_text body_text body_textsv tags_textv text_array_text title_text))
    )
  end

  it 'searches only specified text fields when specified' do
    search do
      keywords 'keyword search', :fields => [:title, :body]
    end
    expect(connection.searches.last[:qf].split(' ').sort).to eq(%w(body_textsv title_text))
  end

  it 'excludes text fields when instructed' do
    search do
      keywords 'keyword search' do
        exclude_fields :backwards_title, :body_mlt
      end
    end
    expect(connection.searches.last[:qf].split(' ').sort).to eq(%w(body_textsv tags_textv text_array_text title_text))
  end

  it 'assigns boost to fields when specified' do
    search do
      keywords 'keyword search' do
        fields :title => 2.0, :body => 0.75
      end
    end
    expect(connection.searches.last[:qf].split(' ').sort).to eq(%w(body_textsv^0.75 title_text^2.0))
  end

  it 'allows assignment of boosted and unboosted fields' do
    search do
      keywords 'keyword search' do
        fields :body, :title => 2.0
      end
    end
  end

  it 'searches both unstored and stored text field with same name when specified' do
    search Post, Namespaced::Comment do
      keywords 'keyword search', :fields => [:body]
    end
    expect(connection.searches.last[:qf].split(' ').sort).to eq(%w(body_text body_textsv))
  end

  it 'requests score when keywords used' do
    search do
      keywords 'keyword search'
    end
    expect(connection).to have_last_search_with(:fl => '* score')
  end

  it 'does not request score when keywords not used' do
    search Post
    expect(connection).not_to have_last_search_with(:fl)
  end

  it 'sets phrase fields' do
    search do
      keywords 'great pizza' do
        phrase_fields :title => 2.0
      end
    end
    expect(connection).to have_last_search_with(:pf => 'title_text^2.0')
  end

  it 'sets phrase fields with boost' do
    search do
      keywords 'great pizza' do
        phrase_fields :title => 1.5
      end
    end
    expect(connection).to have_last_search_with(:pf => 'title_text^1.5')
  end

  it 'sets phrase slop from DSL' do
    search do
      keywords 'great pizza' do
        phrase_slop 2
      end
    end
    expect(connection).to have_last_search_with(:ps => 2)
  end

  it 'sets boost for certain fields without restricting fields' do
    search do
      keywords 'great pizza' do
        boost_fields :title => 1.5
      end
    end
    expect(connection.searches.last[:qf].split(' ').sort).to(
      eq(%w(backwards_title_text body_textsv tags_textv text_array_text title_text^1.5))
    )
  end

  it 'ignores boost fields that do not apply' do
    search do
      keywords 'great pizza' do
        boost_fields :bogus => 1.2, :title => 1.5
      end
    end
    expect(connection.searches.last[:qf].split(' ').sort).to(
      eq(%w(backwards_title_text body_textsv tags_textv text_array_text title_text^1.5))
    )
  end

  it 'sets default boost with default fields' do
    search Photo do
      keywords 'great pizza'
    end
    # Hashes in 1.8 aren't ordered
    expect(connection.searches.last[:qf].split(" ").sort.join(" ")).to eq 'caption_text^1.5 description_text'
  end

  it 'sets default boost with fields specified in options' do
    search Photo do
      keywords 'great pizza', :fields => [:caption]
    end
    expect(connection).to have_last_search_with(:qf => 'caption_text^1.5')
  end

  it 'sets default boost with fields specified in DSL' do
    search Photo do
      keywords 'great pizza' do
        fields :caption
      end
    end
    expect(connection).to have_last_search_with(:qf => 'caption_text^1.5')
  end

  it 'overrides default boost when specified in DSL' do
    search Photo do
      keywords 'great pizza' do
        fields :caption => 2.0
      end
    end
    expect(connection).to have_last_search_with(:qf => 'caption_text^2.0')
  end

  it 'creates boost query' do
    search do
      keywords 'great pizza' do
        boost 2.0 do
          with(:average_rating).greater_than(2.0)
        end
      end
    end
    expect(connection).to have_last_search_with(:bq => ['average_rating_ft:{2\.0 TO *}^2.0'])
  end

  it 'creates multiple boost queries' do
    search do
      keywords 'great pizza' do
        boost(2.0) do
          with(:average_rating).greater_than(2.0)
        end
        boost(1.5) do
          with(:featured, true)
        end
      end
    end
    expect(connection).to have_last_search_with(
      :bq => [
        'average_rating_ft:{2\.0 TO *}^2.0',
        'featured_bs:true^1.5'
      ]
    )
  end

  it 'sends minimum match parameter from options' do
    search do
      keywords 'great pizza', :minimum_match => 2
    end
    expect(connection).to have_last_search_with(:mm => 2)
  end

  it 'sends minimum match parameter from DSL' do
    search do
      keywords('great pizza') { minimum_match(2) }
    end
    expect(connection).to have_last_search_with(:mm => 2)
  end

  it 'sends tiebreaker parameter from options' do
    search do
      keywords 'great pizza', :tie => 0.1
    end
    expect(connection).to have_last_search_with(:tie => 0.1)
  end

  it 'sends tiebreaker parameter from DSL' do
    search do
      keywords('great pizza') { tie(0.1) }
    end
    expect(connection).to have_last_search_with(:tie => 0.1)
  end

  it 'sends query phrase slop from options' do
    search do
      keywords 'great pizza', :query_phrase_slop => 2
    end
    expect(connection).to have_last_search_with(:qs => 2)
  end

  it 'sends query phrase slop from DSL' do
    search do
      keywords('great pizza') { query_phrase_slop(2) }
    end
    expect(connection).to have_last_search_with(:qs => 2)
  end

  it 'allows specification of a text field that only exists in one type' do
    search Post, Namespaced::Comment do
      keywords 'keywords', :fields => :author_name
    end
    expect(connection.searches.last[:qf]).to eq('author_name_text')
  end

  it 'raises Sunspot::UnrecognizedFieldError for nonexistant fields in keywords' do
    expect do
      search do
        keywords :text, :fields => :bogus
      end
    end.to raise_error(Sunspot::UnrecognizedFieldError)
  end

  it 'raises Sunspot::UnrecognizedFieldError if a text field that does not exist for any type is specified' do
    expect do
      search Post, Namespaced::Comment do
        keywords 'fulltext', :fields => :bogus
      end
    end.to raise_error(Sunspot::UnrecognizedFieldError)
  end

  describe 'connective examples' do
    it 'creates a disjunction between two subqueries' do
      search Post do
        any do
          fulltext 'keywords1', :fields => :title
          fulltext 'keyword2', :fields => :body
        end
      end

      expect(connection.searches.last[:q]).to eq "(_query_:\"{!edismax qf='title_text'}keywords1\" OR _query_:\"{!edismax qf='body_textsv'}keyword2\")"
    end

    it 'creates a conjunction inside of a disjunction' do
      search do
        any do
          fulltext 'keywords1', :fields => :body

          all do
            fulltext 'keyword2', :fields => :body
            fulltext 'keyword3', :fields => :body
          end
        end
      end

      expect(connection.searches.last[:q]).to eq "(_query_:\"{!edismax qf='body_textsv'}keywords1\" OR (_query_:\"{!edismax qf='body_textsv'}keyword2\" AND _query_:\"{!edismax qf='body_textsv'}keyword3\"))"
    end

    it 'does nothing special if #all/#any called from the top level or called multiple times' do
      search Post do
        all do
          fulltext 'keywords1', :fields => :title
          fulltext 'keyword2', :fields => :body
        end
      end

      expect(connection.searches.last[:q]).to eq "(_query_:\"{!edismax qf='title_text'}keywords1\" AND _query_:\"{!edismax qf='body_textsv'}keyword2\")"
    end

    it 'does nothing special if #all/#any are mixed and called multiple times' do
      search Post do
        all do
          any do
            all do
              fulltext 'keywords1', :fields => :title
              fulltext 'keyword2', :fields => :body
            end
          end
        end
      end

      expect(connection.searches.last[:q]).to eq "(_query_:\"{!edismax qf='title_text'}keywords1\" AND _query_:\"{!edismax qf='body_textsv'}keyword2\")"

      search Post do
        any do
          all do
            any do
              fulltext 'keywords1', :fields => :title
              fulltext 'keyword2', :fields => :body
            end
          end
        end
      end

      expect(connection.searches.last[:q]).to eq "(_query_:\"{!edismax qf='title_text'}keywords1\" OR _query_:\"{!edismax qf='body_textsv'}keyword2\")"
    end

    it "does not add empty parentheses" do
      search Post do
        any do
          all do
          end

          any do
            fulltext 'keywords1', :fields => :title
            all do
            end
          end
        end
      end

      expect(connection.searches.last[:q]).to eq "_query_:\"{!edismax qf='title_text'}keywords1\""
    end
  end

  describe "joins" do
    it "should search by join" do
      srch = search PhotoContainer do
        any do
          fulltext 'keyword1', :fields => :caption
          fulltext 'keyword2', :fields => :description
        end
      end

      obj_id = find_ob_id(srch)
      q_name = "qPhoto#{obj_id}"

      expect(connection.searches.last[:q]).to eq "(_query_:\"{!join from=photo_container_id_i to=id_i v=$#{q_name}}\" OR _query_:\"{!edismax qf='description_text^1.2'}keyword2\")"
      expect(connection.searches.last[q_name]).to eq "_query_:\"{!field f=type}Photo\"+_query_:\"{!edismax qf='caption_text'}keyword1\""
    end

    it "should be able to resolve name conflicts with the :prefix option" do
      srch = search PhotoContainer do
        any do
          fulltext 'keyword1', :fields => :description
          fulltext 'keyword2', :fields => :photo_description
        end
      end

      obj_id = find_ob_id(srch)
      q_name = "qPhoto#{obj_id}"

      expect(connection.searches.last[:q]).to eq "(_query_:\"{!edismax qf='description_text^1.2'}keyword1\" OR _query_:\"{!join from=photo_container_id_i to=id_i v=$#{q_name}}\")"
      expect(connection.searches.last[q_name]).to eq "_query_:\"{!field f=type}Photo\"+_query_:\"{!edismax qf='description_text'}keyword2\""
    end

    it "should recognize fields when adding from DSL, e.g. when calling boost_fields" do
      srch = search PhotoContainer do
        any do
          fulltext 'keyword1', :fields => [:photo_description, :description] do
            boost_fields(:photo_description => 1.3, :description => 1.5)
          end
        end
      end

      obj_id = find_ob_id(srch)
      q_name = "qPhoto#{obj_id}"

      expect(connection.searches.last[:q]).to eq "(_query_:\"{!edismax qf='description_text^1.5'}keyword1\" OR _query_:\"{!join from=photo_container_id_i to=id_i v=$#{q_name}}\")"
      expect(connection.searches.last[q_name]).to eq "_query_:\"{!field f=type}Photo\"+_query_:\"{!edismax qf='description_text^1.3'}keyword1\""
    end

    private

    def find_ob_id(search)
      search.query.
        instance_variable_get("@components").find { |c| c.is_a?(Sunspot::Query::Conjunction) }.
        instance_variable_get("@components").find { |c| c.is_a?(Sunspot::Query::Disjunction) }.
        instance_variable_get("@components").find { |c| c.is_a?(Sunspot::Query::Join) }.
        object_id
    end
  end
end
