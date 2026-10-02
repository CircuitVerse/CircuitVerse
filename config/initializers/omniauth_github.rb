# frozen_string_literal: true

require "omniauth/strategies/github"

# Fetch GitHub's two profile endpoints concurrently so they stop running back to
# back during login (issue #7875).
#
# With the user:email scope (config/initializers/devise.rb) omniauth-github needs
# both GET /user (the uid and name) and GET /user/emails (the primary verified
# email). The stock strategy resolves them lazily and sequentially, so every
# GitHub login issued three consecutive external requests -- the token exchange,
# then /user, then /user/emails -- which is what Sentry's "Consecutive HTTP"
# detector flagged (~700ms per login).
#
# Both requests depend only on the access token, so we issue them in parallel and
# memoise the results. This drops one sequential round-trip from every login
# while leaving the resolved data untouched: #email still returns the primary
# verified address, so account matching in User.from_omniauth is unaffected.
module OmniauthGithubParallelProfileFetch
  # Returns the raw user profile payload from GitHub's GET /user endpoint,
  # ensuring profile data is prefetched concurrently if not already memoized.
  #
  # @return [Hash] the parsed JSON payload from GET /user
  def raw_info
    prefetch_github_profile!
    @raw_info
  end

  # Returns the list of email hashes from GitHub's GET /user/emails endpoint,
  # ensuring profile data is prefetched concurrently if not already memoized.
  # Returns an empty array if email access is not allowed by the granted scopes.
  #
  # @return [Array<Hash>] list of parsed email objects, or [] if scope disallowed
  def emails
    return [] unless email_access_allowed?

    prefetch_github_profile!
    @emails
  end

  private

    # Initiates concurrent requests for the GitHub user profile and verified email list.
    # If the user profile fetch raises an error, any active background email request
    # is terminated to prevent orphaned in-flight requests. Results are memoized only
    # after both requests complete successfully.
    #
    # @return [void]
    def prefetch_github_profile!
      return if @github_profile_prefetched

      # Resolve the token once and pin the transport mode the way the stock
      # strategy does (raw_info/emails both set :mode => :header), so the two
      # requests share one immutable token and send the credential identically.
      # The write happens before the thread starts, so it is visible to it.
      token = access_token
      token.options[:mode] = :header

      emails_request = Thread.new { fetch_github_emails(token) } if email_access_allowed?
      begin
        user_info = fetch_github_user(token)
        user_emails = emails_request ? emails_request.value : []
      rescue StandardError
        emails_request&.kill
        raise
      end

      @raw_info = user_info
      @emails = user_emails
      @github_profile_prefetched = true
    end

    # Fetches and parses the authenticated user profile from GitHub.
    #
    # @param token [OAuth2::AccessToken] the OAuth access token
    # @return [Hash] the parsed user profile hash
    def fetch_github_user(token)
      token.get("user").parsed
    end

    # Fetches and parses the verified email addresses from GitHub.
    #
    # @param token [OAuth2::AccessToken] the OAuth access token
    # @return [Array<Hash>] the list of email hashes
    def fetch_github_emails(token)
      token.get("user/emails", headers: { "Accept" => "application/vnd.github.v3" }).parsed
    end
end

OmniAuth::Strategies::GitHub.prepend(OmniauthGithubParallelProfileFetch)

