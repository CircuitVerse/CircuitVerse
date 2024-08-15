module RSolr
  require 'rsolr/version'

  autoload :Char, 'rsolr/char'
  autoload :Client, 'rsolr/client'
  autoload :Document, 'rsolr/document'
  autoload :Error, 'rsolr/error'
  autoload :Field, 'rsolr/field'
  autoload :Generator, 'rsolr/generator'
  autoload :HashWithResponse, 'rsolr/response'
  autoload :JSON, 'rsolr/json'
  autoload :Response, 'rsolr/response'
  autoload :Uri, 'rsolr/uri'
  autoload :Xml, 'rsolr/xml'

  def self.connect *args
    opts = args.pop if args.last.is_a?(::Hash)
    opts ||= {}

    connection = args.first

    Client.new connection, opts
  end

  # backslash escape characters that have special meaning to Solr query parser
  # per http://lucene.apache.org/core/4_0_0/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#Escaping_Special_Characters
  #  + - & | ! ( ) { } [ ] ^ " ~ * ? : \ /
  # see also http://svn.apache.org/repos/asf/lucene/dev/tags/lucene_solr_4_9_1/solr/solrj/src/java/org/apache/solr/client/solrj/util/ClientUtils.java
  #   escapeQueryChars method
  # @return [String] str with special chars preceded by a backslash
  def self.solr_escape(str)
    # note that the gsub will parse the escaped backslashes, as will the ruby code sending the query to Solr 
    # so the result sent to Solr is ultimately a single backslash in front of the particular character 
    str.gsub(/([+\-&|!\(\)\{\}\[\]\^"~\*\?:\\\/])/, '\\\\\1')
  end

  module Array
    def self.wrap(object)
      if object.nil?
        [nil]
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      elsif object.is_a? Hash
        [object]
      elsif object.is_a? Enumerable
        object
      else
        [object]
      end
    end
  end
end
