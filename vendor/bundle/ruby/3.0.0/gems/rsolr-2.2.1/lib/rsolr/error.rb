module RSolr::Error

  module SolrContext

    attr_accessor :request, :response

    def to_s
      m = "#{super.to_s}"
      if response
        m << " - #{response[:status]} #{Http::STATUS_CODES[response[:status].to_i]}"
        details = parse_solr_error_response response[:body]
        m << "\nError: #{details}\n" if details
      end
      p = "\nURI: #{request[:uri].to_s}"
      p << "\nRequest Headers: #{request[:headers].inspect}" if request[:headers]
      p << "\nRequest Data: #{request[:data].inspect}" if request[:data]
      p << "\n"
      p << "\nBacktrace: " + self.backtrace[0..10].join("\n")
      m << p
      m
    end

    protected

    def parse_solr_error_response body
      begin
        if body =~ /<pre>/
          info = body.scan(/<pre>(.*)<\/pre>/mi)[0]
        elsif body =~ /'msg'=>/
          info = body.scan(/'msg'=>(.*)/)[0]
        end
        info = info.join if info.respond_to? :join
        info ||= body  # body might not contain <pre> or msg elements

        partial = info.to_s.split("\n")[0..10]
        partial.join("\n").gsub("&gt;", ">").gsub("&lt;", "<")
      rescue
        nil
      end
    end


  end

  class ConnectionRefused < ::Errno::ECONNREFUSED
  end

  class Http < RuntimeError

    include SolrContext

    # ripped right from ActionPack
    # Defines the standard HTTP status codes, by integer, with their
    # corresponding default message texts.
    # Source: http://www.iana.org/assignments/http-status-codes
    STATUS_CODES = {
      100 => "Continue",
      101 => "Switching Protocols",
      102 => "Processing",

      200 => "OK",
      201 => "Created",
      202 => "Accepted",
      203 => "Non-Authoritative Information",
      204 => "No Content",
      205 => "Reset Content",
      206 => "Partial Content",
      207 => "Multi-Status",
      226 => "IM Used",

      300 => "Multiple Choices",
      301 => "Moved Permanently",
      302 => "Found",
      303 => "See Other",
      304 => "Not Modified",
      305 => "Use Proxy",
      307 => "Temporary Redirect",

      400 => "Bad Request",
      401 => "Unauthorized",
      402 => "Payment Required",
      403 => "Forbidden",
      404 => "Not Found",
      405 => "Method Not Allowed",
      406 => "Not Acceptable",
      407 => "Proxy Authentication Required",
      408 => "Request Timeout",
      409 => "Conflict",
      410 => "Gone",
      411 => "Length Required",
      412 => "Precondition Failed",
      413 => "Request Entity Too Large",
      414 => "Request-URI Too Long",
      415 => "Unsupported Media Type",
      416 => "Requested Range Not Satisfiable",
      417 => "Expectation Failed",
      422 => "Unprocessable Entity",
      423 => "Locked",
      424 => "Failed Dependency",
      426 => "Upgrade Required",

      500 => "Internal Server Error",
      501 => "Not Implemented",
      502 => "Bad Gateway",
      503 => "Service Unavailable",
      504 => "Gateway Timeout",
      505 => "HTTP Version Not Supported",
      507 => "Insufficient Storage",
      510 => "Not Extended"
    }

    def initialize request, response
      @request, @response = request, response
    end

  end

  # Thrown if the :wt is :ruby
  # but the body wasn't succesfully parsed/evaluated
  class InvalidResponse < Http

  end

  # Thrown if the :wt is :ruby
  # but the body wasn't succesfully parsed/evaluated
  class InvalidJsonResponse < InvalidResponse

  end

  # Thrown if the :wt is :ruby
  # but the body wasn't succesfully parsed/evaluated
  class InvalidRubyResponse < InvalidResponse

  end

end
