module RSolr
  class Document
    CHILD_DOCUMENT_KEY = '_childDocuments_'.freeze

    # "attrs" is a hash for setting the "doc" xml attributes
    # "fields" is an array of Field objects
    attr_accessor :attrs, :fields

    # "doc_hash" must be a Hash/Mash object
    # If a value in the "doc_hash" is an array,
    # a field object is created for each value...
    def initialize(doc_hash = {})
      @fields = []
      doc_hash.each_pair do |field, values|
        add_field(field, values)
      end
      @attrs={}
    end

    # returns an array of fields that match the "name" arg
    def fields_by_name(name)
      @fields.select{|f|f.name==name}
    end

    # returns the *first* field that matches the "name" arg
    def field_by_name(name)
      @fields.detect{|f|f.name==name}
    end

    #
    # Add a field value to the document. Options map directly to
    # XML attributes in the Solr <field> node.
    # See http://wiki.apache.org/solr/UpdateXmlMessages#head-8315b8028923d028950ff750a57ee22cbf7977c6
    #
    # === Example:
    #
    #   document.add_field('title', 'A Title', :boost => 2.0)
    #
    def add_field(name, values, options = {})
      RSolr::Array.wrap(values).each do |v|
        field_attrs = { name: name }
        field_attrs[:type] = DocumentField if name.to_s == CHILD_DOCUMENT_KEY

        @fields << RSolr::Field.instance(options.merge(field_attrs), v)
      end
    end

    def as_json
      @fields.group_by(&:name).each_with_object({}) do |(field, values), result|
        v = values.map(&:as_json)
        if v.length > 1 && v.first.is_a?(Hash) && v.first.key?(:value)
          v = v.first.merge(value: v.map { |single| single[:value] })
        end
        v = v.first if v.length == 1 && field.to_s != CHILD_DOCUMENT_KEY
        result[field] = v
      end
    end
  end
end
