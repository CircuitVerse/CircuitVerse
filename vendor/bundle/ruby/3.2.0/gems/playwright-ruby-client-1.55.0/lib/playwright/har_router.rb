module Playwright
  class HarRouter
    # @param local_utils [LocalUtils]
    # @param file [String]
    # @param not_found_action [String] 'abort' or 'fallback'
    # @param url_match [String||Regexp|nil]
    def self.create(local_utils, file, not_found_action, url_match: nil)
      har_id = local_utils.har_open(file)

      new(
        local_utils: local_utils,
        har_id: har_id,
        not_found_action: not_found_action,
        url_match: url_match,
      )
    end

    # @param local_utils [LocalUtils]
    # @param har_id [String]
    # @param not_found_action [String] 'abort' or 'fallback'
    # @param url_match [String||Regexp|nil]
    def initialize(local_utils:, har_id:, not_found_action:,  url_match: nil)
      unless ['abort', 'fallback'].include?(not_found_action)
        raise ArgumentError.new("not_found_action must be either 'abort' or 'fallback'. '#{not_found_action}' is specified.")
      end

      @local_utils = local_utils
      @har_id = har_id
      @not_found_action = not_found_action
      @url_match = url_match || '**/*'
      @debug = ENV['DEBUG'].to_s == 'true' || ENV['DEBUG'].to_s == '1'
    end

    private def handle(route, request)
      response = @local_utils.har_lookup(
        har_id: @har_id,
        url: request.url,
        method: request.method,
        headers: request.headers_array,
        post_data: request.post_data_buffer,
        is_navigation_request: request.navigation_request?,
      )
      case response['action']
      when 'redirect'
        redirect_url = response['redirectURL']
        puts "pw:api HAR: #{request.url} redirected to #{redirect_url}" if @debug
        route.redirect_navigation_request(redirect_url)
      when 'fulfill'
        # If the response status is -1, the request was canceled or stalled, so we just stall it here.
        # See https://github.com/microsoft/playwright/issues/29311.
        # TODO: it'd be better to abort such requests, but then we likely need to respect the timing,
        # because the request might have been stalled for a long time until the very end of the
        # test when HAR was recorded but we'd abort it immediately.
        return if response['status'] == -1

        route.fulfill(
          status: response['status'],
          headers: response['headers'].map { |header| [header['name'], header['value']] }.to_h,
          body: Base64.strict_decode64(response['body']),
        )
      else
        # Report the error, but fall through to the default handler.
        if response['action'] == 'error'
          puts "pw:api HAR: #{response['message']} redirected to #{redirect_url}" if @debug
        end

        if @not_found_action == 'abort'
          route.abort
        else
          route.fallback
        end
      end
    end

    def add_context_route(context)
      context.route(@url_match, method(:handle))
      context.once(Events::BrowserContext::Close, method(:dispose))
    end

    def add_page_route(page)
      page.route(@url_match, method(:handle))
      page.once(Events::Page::Close, method(:dispose))
    end

    def dispose
      @local_utils.async_har_close(@har_id)
    end
  end
end
