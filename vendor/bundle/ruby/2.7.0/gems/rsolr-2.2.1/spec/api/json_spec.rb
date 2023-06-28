require 'spec_helper'

RSpec.describe RSolr::JSON do

  let(:generator){ RSolr::JSON::Generator.new }

  context :add do
    # add a single hash ("doc")
    it 'should create an add from a hash' do
      data = {
        :id=>"1",
        :name=>'matt'
      }
      message = JSON.parse(generator.add(data), symbolize_names: true)
      expect(message.length).to eq 1
      expect(message.first).to eq data
    end

    # add an array of hashes
    it 'should create many adds from an array of hashes' do
      data = [
        {
          :id=>"1",
          :name=>'matt'
        },
        {
          :id=>"2",
          :name=>'sam'
        }
      ]
      message = JSON.parse(generator.add(data), symbolize_names: true)
      expect(message).to eq data
    end

    it 'should yield a Document object when #add is called with a block' do
      documents = [{:id=>1, :name=>'sam', :cat=>['cat 1', 'cat 2']}]
      result = generator.add(documents) do |doc|
        doc.field_by_name(:name).attrs[:boost] = 10
      end

      message = JSON.parse(result, symbolize_names: true)

      expect(message.length).to eq 1
      expect(message.first).to include name: { boost: 10, value: 'sam' }
    end

    context 'with add_attr' do
      it 'should create an add command with the attributes from a hash' do
        data = {
          :id=>"1",
          :name=>'matt'
        }
        message = JSON.parse(generator.add(data, boost: 1), symbolize_names: true)
        expect(message).to include :add
        expect(message[:add][:doc]).to eq data
        expect(message[:add][:boost]).to eq 1
      end

      it 'should create multiple add command with the attributes from a hash' do
        data = [
          {
            :id=>"1",
            :name=>'matt'
          },
          {
            :id=>"2",
            :name=>'sam'
          },
        ]

        # custom JSON object class to handle Solr's non-standard JSON command format
        tmp = Class.new do
          def initialize
            @source ||= {}
          end

          def []=(k, v)
            if k == :add
              @source[k] ||= []
              @source[k] << v.to_h
            elsif v.class == self.class
              @source[k] = v.to_h
            else
              @source[k] = v
            end
          end

          def to_h
            @source
          end
        end

        request = generator.add(data, boost: 1)
        message = JSON.parse(request, object_class: tmp, symbolize_names: true).to_h
        expect(message[:add].length).to eq 2
        expect(message[:add].map { |x| x[:doc] }).to eq data
      end
    end

    it 'allows for atomic updates' do
      data = {
        foo: { set: 'Bar' }
      }

      message = JSON.parse(generator.add(data), symbolize_names: true)
      expect(message.length).to eq 1
      expect(message.first).to eq data
    end

    it 'supports nested child documents' do
      data = {
        _childDocuments_: [
          {
            id: 1
          },
          {
            id: 2
          }
        ]
      }

      message = JSON.parse(generator.add(data), symbolize_names: true)
      expect(message.length).to eq 1
      expect(message.first).to eq data
    end

    it 'supports nested child documents with only a single document' do
      data = {
        _childDocuments_: [
          {
            id: 1
          }
        ]
      }

      message = JSON.parse(generator.add(data), symbolize_names: true)
      expect(message.length).to eq 1
      expect(message.first).to eq data
    end
  end

  it 'should create multiple fields from array values' do
    data = {
      :id   => "1",
      :name => ['matt1', 'matt2']
    }
    message = JSON.parse(generator.add(data), symbolize_names: true)
    expect(message.length).to eq 1
    expect(message.first).to eq data
  end

  it 'should create multiple fields from array values with options' do
    test_values = [nil, 'matt1', 'matt2']
    message = JSON.parse(
      generator.add(id: '1') { |doc| doc.add_field(:name, test_values, boost: 3) },
      symbolize_names: true
    )
    expect(message).to eq [{ id: '1', name: { boost: 3, value: test_values } }]
  end

  describe '#commit' do
    it 'generates a commit command' do
      expect(JSON.parse(generator.commit, symbolize_names: true)).to eq(commit: {})
    end
  end

  describe '#optimize' do
    it 'generates a optimize command' do
      expect(JSON.parse(generator.optimize, symbolize_names: true)).to eq(optimize: {})
    end
  end

  describe '#rollback' do
    it 'generates a rollback command' do
      expect(JSON.parse(generator.rollback, symbolize_names: true)).to eq(rollback: {})
    end
  end

  describe '#delete_by_id' do
    it 'generates a delete_by_id command for single documents' do
      expect(JSON.parse(generator.delete_by_id('x'), symbolize_names: true)).to eq(delete: 'x')
    end

    it 'generates a delete_by_id command for an array of documents' do
      expect(JSON.parse(generator.delete_by_id(%w(a b c)), symbolize_names: true)).to eq(delete: %w(a b c))
    end
  end

  describe '#delete_by_query' do
    it 'generates a delete_by_id command for single documents' do
      expect(JSON.parse(generator.delete_by_query('id:x'), symbolize_names: true)).to eq(delete: { query: 'id:x'})
    end

    it 'generates a delete_by_id command for an array of documents' do
      expect(JSON.parse(generator.delete_by_id(%w(a b c)), symbolize_names: true)).to eq(delete: %w(a b c))
    end
  end
end
