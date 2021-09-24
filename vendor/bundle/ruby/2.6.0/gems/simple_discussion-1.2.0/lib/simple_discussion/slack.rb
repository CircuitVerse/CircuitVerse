require 'open-uri'
require 'net/http'

module SimpleDiscussion
  class Slack
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def post(payload)
      uri          = URI.parse(url)
      request      = Net::HTTP::Post.new(uri)
      req_options  = { use_ssl: uri.scheme == "https", }
      request.body = "payload=#{payload.to_json}"
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
    end
  end
end
