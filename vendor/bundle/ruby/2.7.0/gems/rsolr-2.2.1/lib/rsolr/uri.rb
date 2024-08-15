require 'uri'

module RSolr::Uri
  # Creates a Solr based query string.
  # Keys that have arrays values are set multiple times:
  #   params_to_solr(:q => 'query', :fq => ['a', 'b'])
  # is converted to:
  #   ?q=query&fq=a&fq=b
  # @param [boolean] escape false if no URI escaping is to be performed.  Default true.
  # @return [String] Solr query params as a String, suitable for use in a url
  def self.params_to_solr(params, escape = true)
    return URI.encode_www_form(params.reject{|k,v| k.to_s.empty? || v.to_s.empty?}) if escape

    # escape = false if we are here
    mapped = params.map do |k, v|
      next if v.to_s.empty?
      if v.class == ::Array
        params_to_solr(v.map { |x| [k, x] }, false)
      else
        "#{k}=#{v}"
      end
    end
    mapped.compact.join("&")
  end
end