# frozen_string_literal: true

class OrganizationSocialLinksComponent < ViewComponent::Base
  PROVIDERS = {
    "github.com" => { name: "GitHub", logo: "logos/github-logo-circle.png" },
    "facebook.com" => { name: "Facebook", logo: "logos/facebook-logo.png" },
    "twitter.com" => { name: "X", logo: "logos/twitter-x.png" },
    "x.com" => { name: "X", logo: "logos/twitter-x.png" },
    "youtube.com" => { name: "YouTube", logo: "logos/youtube-logo.png" },
    "linkedin.com" => { name: "LinkedIn", logo: "logos/linkedin-logo.png" }
  }.freeze

  def initialize(links:)
    super()
    @links = links
  end

  def social_links
    Array(@links).compact_blank.map do |link|
      provider = provider_for(url_host(link))
      {
        name: provider[:name],
        url: link,
        logo: provider[:logo]
      }
    end
  end

  private

    def url_host(url)
      uri = URI.parse(url.to_s)
      return nil unless uri.is_a?(URI::HTTP)

      uri.host.to_s.downcase.delete_prefix("www.")
    rescue URI::InvalidURIError
      nil
    end

    def provider_for(host)
      PROVIDERS[base_domain(host)] || default_provider
    end

    def default_provider
      { name: I18n.t("organizations.social_links.website"), logo: "logos/link-logo.png" }
    end

    def base_domain(host)
      host.to_s.split(".").last(2).join(".")
    end
end
