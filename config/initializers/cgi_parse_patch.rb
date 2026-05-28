# Ruby 4.0 removed CGI.parse which is used internally by the ims-lti gem.
# This patch restores CGI.parse for compatibility across all environments.
unless CGI.respond_to?(:parse)
  def CGI.parse(query_string)
    params = {}
    query_string.split("&").each do |pair|
      next if pair.empty?
      key, value = pair.split("=", 2)
      key = CGI.unescape(key.to_s)
      params[key] ||= []
      params[key] << CGI.unescape(value) if value
    end
    params
  end
end