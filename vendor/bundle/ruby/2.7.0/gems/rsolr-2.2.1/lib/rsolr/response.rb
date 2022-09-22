module RSolr::Response

  def self.included(base)
    unless base < Hash
      raise ArgumentError, "RSolr::Response expects to included only in (sub)classes of Hash; got included in '#{base}' instead."
    end
    base.send(:attr_reader, :request, :response)
  end

  def initialize_rsolr_response(request, response, result)
    @request = request
    @response = response
    self.merge!(result)
    if self["response"] && self["response"]["docs"].is_a?(::Array)
      docs = PaginatedDocSet.new(self["response"]["docs"])
      docs.per_page = request[:params]["rows"]
      docs.page_start = request[:params]["start"]
      docs.page_total = self["response"]["numFound"].to_s.to_i
      self["response"]["docs"] = docs
    end
  end

  def with_indifferent_access
    if defined?(::RSolr::HashWithIndifferentAccessWithResponse)
      ::RSolr::HashWithIndifferentAccessWithResponse.new(request, response, self)
    else
      if defined?(ActiveSupport::HashWithIndifferentAccess)
        RSolr.const_set("HashWithIndifferentAccessWithResponse", Class.new(ActiveSupport::HashWithIndifferentAccess))
        RSolr::HashWithIndifferentAccessWithResponse.class_eval <<-eos
          include RSolr::Response
          def initialize(request, response, result)
            super()
            initialize_rsolr_response(request, response, result)
          end
        eos
        ::RSolr::HashWithIndifferentAccessWithResponse.new(request, response, self)
      else
        raise RuntimeError, "HashWithIndifferentAccess is not currently defined"
      end
    end
  end

  # A response module which gets mixed into the solr ["response"]["docs"] array.
  class PaginatedDocSet < ::Array

    attr_accessor :page_start, :per_page, :page_total
    if not (Object.const_defined?("RUBY_ENGINE") and Object::RUBY_ENGINE=='rbx')
      alias_method(:start,:page_start)
      alias_method(:start=,:page_start=)
      alias_method(:total,:page_total)
      alias_method(:total=,:page_total=)
    end

    # Returns the current page calculated from 'rows' and 'start'
    def current_page
      return 1 if start < 1
      per_page_normalized = per_page < 1 ? 1 : per_page
      @current_page ||= (start / per_page_normalized).ceil + 1
    end

    # Calcuates the total pages from 'numFound' and 'rows'
    def total_pages
      @total_pages ||= per_page > 0 ? (total / per_page.to_f).ceil : 1
    end

    # returns the previous page number or 1
    def previous_page
      @previous_page ||= (current_page > 1) ? current_page - 1 : 1
    end

    # returns the next page number or the last
    def next_page
      @next_page ||= (current_page == total_pages) ? total_pages : current_page+1
    end

    def has_next?
      current_page < total_pages
    end

    def has_previous?
      current_page > 1
    end

  end

end

class RSolr::HashWithResponse < Hash
  include RSolr::Response

  def initialize(request, response, result)
    super()
    initialize_rsolr_response(request, response, result || {})
  end
end
