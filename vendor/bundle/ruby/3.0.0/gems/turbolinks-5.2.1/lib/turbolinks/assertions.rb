module Turbolinks
  module Assertions
    TURBOLINKS_VISIT = /Turbolinks\.visit\("([^"]+)", {"action":"([^"]+)"}\)/

    def assert_redirected_to(options = {}, message = nil)
      if turbolinks_request?
        assert_turbolinks_visited(options, message)
      else
        super
      end
    end

    def assert_turbolinks_visited(options = {}, message = nil)
      assert_response(:ok, message)
      assert_equal("text/javascript", response.try(:media_type) || response.content_type)

      visit_location, _ = turbolinks_visit_location_and_action

      redirect_is       = normalize_argument_to_redirection(visit_location)
      redirect_expected = normalize_argument_to_redirection(options)

      message ||= "Expected response to be a Turbolinks visit to <#{redirect_expected}> but was a visit to <#{redirect_is}>"
      assert_operator redirect_expected, :===, redirect_is, message
    end

    # Rough heuristic to detect whether this was a Turbolinks request:
    # non-GET request with a text/javascript response.
    #
    # Technically we'd check that Turbolinks-Referrer request header is
    # also set, but that'd require us to pass the header from post/patch/etc
    # test methods by overriding them to provide a `turbolinks:` option.
    #
    # We can't check `request.xhr?` here, either, since the X-Requested-With
    # header is cleared after controller action processing to prevent it
    # from leaking into subsequent requests.
    def turbolinks_request?
      !request.get? && (response.try(:media_type) || response.content_type) == "text/javascript"
    end

    def turbolinks_visit_location_and_action
      if response.body =~ TURBOLINKS_VISIT
        [ $1, $2 ]
      end
    end
  end
end
