# frozen_string_literal: true

module OrganizationsHelper
  # Returns the organization logo attachment if present,
  # otherwise falls back to the same default image used for user profiles.
  def organization_logo(attachment)
    if attachment.attached?
      attachment
    else
      image_path("/images/thumb/Default.jpg")
    end
  end
  # Returns the FontAwesome class based on the URL domain
  def icon_for_url(url)
    return "fas fa-link" if url.blank?

    domain = url.downcase
    case domain
    when /github\.com/ then "fab fa-github"
    when /instagram\.com/ then "fab fa-instagram"
    when /twitter\.com/, /x\.com/ then "custom-icon-x"
    when /linkedin\.com/ then "fab fa-linkedin"
    when /youtube\.com/, /youtu\.be/ then "fab fa-youtube"
    when /discord\.com/, /discord\.gg/ then "fab fa-discord"
    when /facebook\.com/ then "fab fa-facebook"
    when /slack\.com/ then "fab fa-slack"
    else "fas fa-link"
    end
  end

  # Cleans up the URL for display (removes https:// and trailing slashes)
  def format_url_text(url)
    return "" if url.blank?
    
    url.sub(%r{^https?://(www\.)?}, "").chomp("/")
  end
end
