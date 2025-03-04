# frozen_string_literal: true

class SocialLinksComponent < ViewComponent::Base
  def social_links
    [
      { name: "facebook", url: "/facebook", logo: "logos/facebook-logo.png" },
      { name: "X", url: "/X", logo: "logos/twitter-x.png" },
      { name: "linkedin", url: "/linkedin", logo: "logos/linkedin-logo.png" },
      { name: "youtube", url: "/youtube", logo: "logos/youtube-logo.png" },
      { name: "github", url: "/github", logo: "logos/github-logo-circle.png" }
    ]
  end
end
