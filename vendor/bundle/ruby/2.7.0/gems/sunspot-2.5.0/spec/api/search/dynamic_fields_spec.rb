require File.expand_path('spec_helper', File.dirname(__FILE__))

describe 'search with dynamic fields' do
  it 'returns dynamic string facet' do
    stub_facet(:"custom_string:test_ss", 'two' => 2, 'one' => 1)
    result = session.search(Post) { dynamic(:custom_string) { facet(:test) }}
    expect(result.facet(:custom_string, :test).rows.map { |row| row.value }).to eq(['two', 'one'])
  end

  it 'returns dynamic field facet with custom label' do
    stub_facet(:"bogus", 'two' => 2, 'one' => 1)
    result = session.search(Post) { dynamic(:custom_string) { facet(:test, :name => :bogus) }}
    expect(result.facet(:bogus).rows.map { |row| row.value }).to eq(['two', 'one'])
  end

  it 'returns query facet specified in dynamic call' do
    stub_query_facet(
      'custom_string\:test_ss:(foo OR bar)' => 3
    )
    search = session.search(Post) do
      dynamic :custom_string do
        facet :test do
          row :foo_bar do
            with :test, %w(foo bar)
          end
        end
      end
    end
    facet = search.facet(:test)
    expect(facet.rows.first.value).to eq(:foo_bar)
    expect(facet.rows.first.count).to eq(3)
  end
end
