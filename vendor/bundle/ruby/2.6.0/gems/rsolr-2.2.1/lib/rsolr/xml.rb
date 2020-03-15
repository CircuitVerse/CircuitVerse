module RSolr::Xml
  Document = RSolr::Document
  Field = RSolr::Field

  class Generator < RSolr::Generator
    class << self
      attr_accessor :use_nokogiri

      def builder_proc
        if use_nokogiri 
          require 'nokogiri' unless defined?(::Nokogiri::XML::Builder)
          :nokogiri_build
        else
          require 'builder' unless defined?(::Builder::XmlMarkup)
          :builder_build
        end
      end
    end
    self.use_nokogiri = defined?(::Nokogiri::XML::Builder) ? true : false

    CONTENT_TYPE = 'text/xml'.freeze

    def content_type
      CONTENT_TYPE
    end


    def nokogiri_build &block
      b = ::Nokogiri::XML::Builder.new do |xml|
        block_given? ? yield(xml) : xml
      end
      '<?xml version="1.0" encoding="UTF-8"?>'+b.to_xml(:indent => 0, :encoding => 'UTF-8', :save_with => ::Nokogiri::XML::Node::SaveOptions::AS_XML | ::Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
    end
    protected :nokogiri_build
    
    def builder_build &block
      b = ::Builder::XmlMarkup.new(:indent => 0, :margin => 0, :encoding => 'UTF-8')
      b.instruct!
      block_given? ? yield(b) : b
    end
    protected :builder_build
    
    def build &block
      self.send(self.class.builder_proc,&block)
    end
    
    # generates "add" xml for updating solr
    # "data" can be a hash or an array of hashes.
    # - each hash should be a simple key=>value pair representing a solr doc.
    # If a value is an array, multiple fields will be created.
    #
    # "add_attrs" can be a hash for setting the add xml element attributes.
    # 
    # This method can also accept a block.
    # The value yielded to the block is a Message::Document; for each solr doc in "data".
    # You can set xml element attributes for each "doc" element or individual "field" elements.
    #
    # For example:
    #
    # solr.add({:id=>1, :nickname=>'Tim'}, {:boost=>5.0, :commitWithin=>1.0}) do |doc_msg|
    #   doc_msg.attrs[:boost] = 10.00 # boost the document
    #   nickname = doc_msg.field_by_name(:nickname)
    #   nickname.attrs[:boost] = 20 if nickname.value=='Tim' # boost a field
    # end
    #
    # would result in an add element having the attributes boost="10.0"
    # and a commitWithin="1.0".
    # Each doc element would have a boost="10.0".
    # The "nickname" field would have a boost="20.0"
    # if the doc had a "nickname" field with the value of "Tim".
    #
    def add data, add_attrs = nil, &block
      add_attrs ||= {}
      data = RSolr::Array.wrap(data)
      build do |xml|
        xml.add(add_attrs) do |add_node|
          data.each do |doc|
            doc = RSolr::Document.new(doc) if doc.respond_to?(:each_pair)
            yield doc if block_given?
            doc_node_builder = to_xml(doc)
            self.class.use_nokogiri ? add_node.doc_(doc.attrs,&doc_node_builder) : add_node.doc(doc.attrs,&doc_node_builder)
          end
        end
      end
    end
    
    # generates a <commit/> message
    def commit opts = nil
      opts ||= {}
      build {|xml| xml.commit(opts) }
    end
    
    # generates a <optimize/> message
    def optimize opts = nil
      opts ||= {}
      build {|xml| xml.optimize(opts) }
    end
    
    # generates a <rollback/> message
    def rollback
      build {|xml| xml.rollback({}) }
    end

    # generates a <delete><id>ID</id></delete> message
    # "ids" can be a single value or array of values
    def delete_by_id ids
      ids = RSolr::Array.wrap(ids)
      build do |xml|
        xml.delete do |delete_node|
          ids.each do |id| 
            self.class.use_nokogiri ? delete_node.id_(id) : delete_node.id(id)
          end
        end
      end
    end

    # generates a <delete><query>ID</query></delete> message
    # "queries" can be a single value or an array of values
    def delete_by_query(queries)
      queries = RSolr::Array.wrap(queries)
      build do |xml|
        xml.delete do |delete_node|
          queries.each { |query| delete_node.query(query) }
        end
      end
    end

    private

    def to_xml(doc)
      lambda do |doc_node|
        doc.fields.each do |field_obj|
          value = field_obj.value

          if field_obj.name.to_s == RSolr::Document::CHILD_DOCUMENT_KEY
            child_node_builder = to_xml(field_obj.value)
            self.class.use_nokogiri ? doc_node.doc_(&child_node_builder) : doc_node.doc(&child_node_builder)
          elsif value.is_a?(Hash) && value.length == 1 && field_obj.attrs[:update].nil?
            update_attr, real_value = value.first
            doc_node.field real_value, field_obj.attrs.merge(update: update_attr)
          elsif value.nil?
            doc_node.field field_obj.value, field_obj.attrs.merge(null: true)
          else
            doc_node.field field_obj.value, field_obj.attrs
          end
        end
      end
    end
  end
end
