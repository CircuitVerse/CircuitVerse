# frozen_string_literal: true

class OrganizationSocialLinksComponent < ViewComponent::Base
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
      case base_domain(host)
      when "github.com" then { name: "GitHub", logo: "logos/github-logo-circle.png" }
      when "facebook.com" then { name: "Facebook", logo: "logos/facebook-logo.png" }
      when "twitter.com", "x.com" then { name: "X", logo: "logos/twitter-x.png" }
      when "youtube.com" then { name: "YouTube", logo: "logos/youtube-logo.png" }
      when "linkedin.com" then { name: "LinkedIn", logo: "logos/linkedin-logo.png" }
      else { name: I18n.t("organizations.social_links.website"), logo: "logos/link-logo.png" }
      end
    end

    def base_domain(host)
      host.to_s.split(".").last(2).join(".")
    end
end
