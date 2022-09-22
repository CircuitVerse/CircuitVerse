require 'json'

module RSolr::JSON
  class Generator < RSolr::Generator
    CONTENT_TYPE = 'application/json'.freeze

    def content_type
      CONTENT_TYPE
    end

    def add data, add_attrs = {}
      add_attrs ||= {}
      data = RSolr::Array.wrap(data)

      if add_attrs.empty? && data.none? { |doc| doc.is_a?(RSolr::Document) && !doc.attrs.empty? }
        data.map do |doc|
          doc = RSolr::Document.new(doc) if doc.respond_to?(:each_pair)
          yield doc if block_given?
          doc.as_json
        end.to_json
      else
        i = 0
        data.each_with_object({}) do |doc, hash|
          doc = RSolr::Document.new(doc) if doc.respond_to?(:each_pair)
          yield doc if block_given?
          hash["add__UNIQUE_RSOLR_SUFFIX_#{i += 1}"] = add_attrs.merge(doc.attrs).merge(doc: doc.as_json)
        end.to_json.gsub(/__UNIQUE_RSOLR_SUFFIX_\d+/, '')
      end
    end

    # generates a commit message
    def commit(opts = {})
      opts ||= {}
      { commit: opts }.to_json
    end

    # generates a optimize message
    def optimize(opts = {})
      opts ||= {}
      { optimize: opts }.to_json
    end

    # generates a rollback message
    def rollback
      { rollback: {} }.to_json
    end

    # generates a delete message
    # "ids" can be a single value or array of values
    def delete_by_id(ids)
      { delete: ids }.to_json
    end

    # generates a delete message
    # "queries" can be a single value or an array of values
    def delete_by_query(queries)
      { delete: { query: queries } }.to_json
    end
  end
end
