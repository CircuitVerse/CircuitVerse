# frozen_string_literal: true

require 'json'
require 'faraday'
require 'uri'

class RSolr::Client
  DEFAULT_URL = 'http://127.0.0.1:8983/solr/'

  class << self
    def default_wt
      @default_wt ||= :json
    end

    def default_wt= value
      @default_wt = value
    end
  end

  attr_reader :uri, :proxy, :update_format, :options, :update_path

  def initialize connection, options = {}
    @proxy = @uri = nil
    @connection = connection
    unless false === options[:url]
      @uri = extract_url_from_options(options)
      if options[:proxy]
        proxy_url = options[:proxy].dup
        proxy_url << "/" unless proxy_url.nil? or proxy_url[-1] == ?/
        @proxy = ::URI.parse proxy_url if proxy_url
      elsif options[:proxy] == false
        @proxy = false  # used to avoid setting the proxy from the environment.
      end
    end
    @update_format = options.delete(:update_format) || RSolr::JSON::Generator
    @update_path = options.fetch(:update_path, 'update')
    @options = options
  end

  def extract_url_from_options(options)
    url = options[:url] ? options[:url].dup : DEFAULT_URL
    url << "/" unless url[-1] == ?/
    uri = ::URI.parse(url)
    # URI::HTTPS is a subclass of URI::HTTP, so this check accepts HTTP(S)
    raise ArgumentError, "You must provide an HTTP(S) url." unless uri.kind_of?(URI::HTTP)
    uri
  end

  # returns the request uri object.
  def base_request_uri
    base_uri.request_uri if base_uri
  end

  # returns the URI uri object.
  def base_uri
    @uri
  end

  # Create the get, post, and head methods
  %W(get post head).each do |meth|
    class_eval <<-RUBY
    def #{meth} path, opts = {}, &block
      send_and_receive path, opts.merge(:method => :#{meth}), &block
    end
    RUBY
  end

  # A paginated request method.
  # Converts the page and per_page
  # arguments into "rows" and "start".
  def paginate page, per_page, path, opts = nil
    opts ||= {}
    opts[:params] ||= {}
    raise "'rows' or 'start' params should not be set when using +paginate+" if ["start", "rows"].include?(opts[:params].keys)
    execute build_paginated_request(page, per_page, path, opts)
  end

  # POST XML messages to /update with optional params.
  #
  # http://wiki.apache.org/solr/UpdateXmlMessages#add.2BAC8-update
  #
  # If not set, opts[:headers] will be set to a hash with the key
  # 'Content-Type' set to 'text/xml'
  #
  # +opts+ can/should contain:
  #
  #  :data - posted data
  #  :headers - http headers
  #  :params - solr query parameter hash
  #
  def update opts = {}
    opts[:headers] ||= {}
    opts[:headers]['Content-Type'] ||= builder.content_type
    post opts.fetch(:path, update_path), opts
  end

  # +add+ creates xml "add" documents and sends the xml data to the +update+ method
  #
  # http://wiki.apache.org/solr/UpdateXmlMessages#add.2BAC8-update
  #
  # single record:
  # solr.add(:id=>1, :name=>'one')
  #
  # add using an array
  #
  # solr.add(
  #   [{:id=>1, :name=>'one'}, {:id=>2, :name=>'two'}],
  #   :add_attributes => {:boost=>5.0, :commitWithin=>10}
  # )
  #
  def add doc, opts = {}
    add_attributes = opts.delete :add_attributes
    update opts.merge(:data => builder.add(doc, add_attributes))
  end

  # send "commit" xml with opts
  #
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22commit.22_and_.22optimize.22
  #
  def commit opts = {}
    commit_attrs = opts.delete :commit_attributes
    update opts.merge(:data => builder.commit( commit_attrs ))
  end

  # send "optimize" xml with opts.
  #
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22commit.22_and_.22optimize.22
  #
  def optimize opts = {}
    optimize_attributes = opts.delete :optimize_attributes
    update opts.merge(:data => builder.optimize(optimize_attributes))
  end

  # send </rollback>
  #
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22rollback.22
  #
  # NOTE: solr 1.4 only
  def rollback opts = {}
    update opts.merge(:data => builder.rollback)
  end

  # Delete one or many documents by id
  #   solr.delete_by_id 10
  #   solr.delete_by_id([12, 41, 199])
  def delete_by_id id, opts = {}
    update opts.merge(:data => builder.delete_by_id(id))
  end

  # delete one or many documents by query.
  #
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22delete.22_by_ID_and_by_Query
  #
  #   solr.delete_by_query 'available:0'
  #   solr.delete_by_query ['quantity:0', 'manu:"FQ"']
  def delete_by_query query, opts = {}
    update opts.merge(:data => builder.delete_by_query(query))
  end

  def builder
    @builder ||= if update_format.is_a? Class
                   update_format.new
                 elsif update_format == :json
                   RSolr::JSON::Generator.new
                 elsif update_format == :xml
                   RSolr::Xml::Generator.new
                 else
                   update_format
                 end
  end

  # +send_and_receive+ is the main request method responsible for sending requests to the +connection+ object.
  #
  # "path" : A string value that usually represents a solr request handler
  # "opts" : A hash, which can contain the following keys:
  #   :method : required - the http method (:get, :post or :head)
  #   :params : optional - the query string params in hash form
  #   :data : optional - post data -- if a hash is given, it's sent as "application/x-www-form-urlencoded; charset=UTF-8"
  #   :headers : optional - hash of request headers
  # All other options are passed right along to the connection's +send_and_receive+ method (:get, :post, or :head)
  #
  # +send_and_receive+ returns either a string or hash on a successful ruby request.
  # When the :params[:wt] => :ruby, the response will be a hash, else a string.
  #
  # creates a request context hash,
  # sends it to the connection's +execute+ method
  # which returns a simple hash,
  # then passes the request/response into +adapt_response+.
  def send_and_receive path, opts
    request_context = build_request path, opts
    execute request_context
  end

  #
  def execute request_context
    raw_response = begin
      response = connection.send(request_context[:method], request_context[:uri].to_s) do |req|
        req.body = request_context[:data] if request_context[:method] == :post and request_context[:data]
        req.headers.merge!(request_context[:headers]) if request_context[:headers]
      end

      { status: response.status.to_i, headers: response.headers, body: response.body.force_encoding('utf-8') }
    rescue Errno::ECONNREFUSED, Faraday::Error::ConnectionFailed
      raise RSolr::Error::ConnectionRefused, request_context.inspect
    rescue Faraday::Error => e
      raise RSolr::Error::Http.new(request_context, e.response)
    end
    adapt_response(request_context, raw_response) unless raw_response.nil?
  end

  # +build_request+ accepts a path and options hash,
  # then prepares a normalized hash to return for sending
  # to a solr connection driver.
  # +build_request+ sets up the uri/query string
  # and converts the +data+ arg to form-urlencoded,
  # if the +data+ arg is a hash.
  # returns a hash with the following keys:
  #   :method
  #   :params
  #   :headers
  #   :data
  #   :uri
  #   :path
  #   :query
  def build_request path, opts
    raise "path must be a string or symbol, not #{path.inspect}" unless [String,Symbol].include?(path.class)
    path = path.to_s
    opts[:proxy] = proxy unless proxy.nil?
    opts[:method] ||= :get
    raise "The :data option can only be used if :method => :post" if opts[:method] != :post and opts[:data]
    opts[:params] = params_with_wt(opts[:params])
    query = RSolr::Uri.params_to_solr(opts[:params]) unless opts[:params].empty?
    opts[:query] = query
    if opts[:data].is_a? Hash
      opts[:data] = RSolr::Uri.params_to_solr opts[:data]
      opts[:headers] ||= {}
      opts[:headers]['Content-Type'] ||= 'application/x-www-form-urlencoded; charset=UTF-8'
    end
    opts[:path] = path
    opts[:uri] = base_uri.merge(path.to_s + (query ? "?#{query}" : "")) if base_uri

    opts
  end

  def params_with_wt(params)
    return { wt: default_wt } if params.nil?
    return params if params.key?(:wt) || params.key?('wt')
    { wt: default_wt }.merge(params)
  end

  def build_paginated_request page, per_page, path, opts
    per_page = per_page.to_s.to_i
    page = page.to_s.to_i-1
    page = page < 1 ? 0 : page
    opts[:params]["start"] = page * per_page
    opts[:params]["rows"] = per_page
    build_request path, opts
  end

  # This method will evaluate the :body value
  # if the params[:uri].params[:wt] == :ruby
  # ... otherwise, the body is returned as is.
  # The return object has methods attached, :request and :response.
  # These methods give you access to the original
  # request and response from the connection.
  #
  # +adapt_response+ will raise an InvalidRubyResponse
  # if :wt == :ruby and the body
  # couldn't be evaluated.
  def adapt_response request, response
    raise "The response does not have the correct keys => :body, :headers, :status" unless
      %W(body headers status) == response.keys.map{|k|k.to_s}.sort

    result = if respond_to? "evaluate_#{request[:params][:wt]}_response", true
      send "evaluate_#{request[:params][:wt]}_response", request, response
    else
      response[:body]
    end

    if result.is_a?(Hash) || request[:method] == :head
      result = RSolr::HashWithResponse.new(request, response, result)
    end

    result
  end
  
  def connection
    @connection ||= begin
      conn_opts = { request: {} }
      conn_opts[:url] = uri.to_s
      conn_opts[:proxy] = proxy if proxy
      conn_opts[:request][:open_timeout] = options[:open_timeout] if options[:open_timeout]
      conn_opts[:request][:timeout] = options[:read_timeout] if options[:read_timeout]
      conn_opts[:request][:params_encoder] = Faraday::FlatParamsEncoder

      Faraday.new(conn_opts) do |conn|
        conn.basic_auth(uri.user, uri.password) if uri.user && uri.password
        conn.response :raise_error
        conn.request :retry, max: options[:retry_after_limit], interval: 0.05,
                             interval_randomness: 0.5, backoff_factor: 2,
                             exceptions: ['Faraday::Error', 'Timeout::Error'] if options[:retry_503]
        conn.adapter options[:adapter] || Faraday.default_adapter
      end
    end
  end

  protected

  # converts the method name for the solr request handler path.
  def method_missing name, *args
    if name.to_s =~ /^paginated?_(.+)$/
      paginate args[0], args[1], $1, *args[2..-1]
    else
      send_and_receive name, *args
    end
  end

  # evaluates the response[:body],
  # attempts to bring the ruby string to life.
  # If a SyntaxError is raised, then
  # this method intercepts and raises a
  # RSolr::Error::InvalidRubyResponse
  # instead, giving full access to the
  # request/response objects.
  def evaluate_ruby_response request, response
    Kernel.eval response[:body].to_s
  rescue SyntaxError
    raise RSolr::Error::InvalidRubyResponse.new request, response
  end

  def evaluate_json_response request, response
    return if response[:body].nil? || response[:body].empty?

    JSON.parse response[:body].to_s
  rescue JSON::ParserError
    raise RSolr::Error::InvalidJsonResponse.new request, response
  end

  def default_wt
    self.options[:default_wt] || self.class.default_wt
  end
end
