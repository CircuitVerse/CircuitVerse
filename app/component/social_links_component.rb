# frozen_string_literal: true

class SocialLinksComponent < ViewComponent::Base
  def social_links
    [
      { name: "facebook", url: "https://www.facebook.com/CircuitVerse", logo: "logos/facebook-logo.png" },
      { name: "twitter", url: "https://twitter.com/CircuitVerse", logo: "logos/twitter-x.png" },
      { name: "linkedin", url: "https://www.linkedin.com/company/circuitverse", logo: "logos/linkedin-logo.png" },
      { name: "youtube", url: "https://www.youtube.com/c/CircuitVerse", logo: "logos/youtube-logo.png" },
      { name: "github", url: "https://github.com/CircuitVerse", logo: "logos/github-logo-circle.png" }
    ]
  end
end
