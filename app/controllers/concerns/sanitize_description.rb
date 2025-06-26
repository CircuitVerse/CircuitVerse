# frozen_string_literal: true

module SanitizeDescription
  extend ActiveSupport::Concern

  def sanitize_description(description)
    sanitize(
      description,
      tags: %w[img p strong em a sup sub del u span h1 h2 h3 h4 hr li ol ul blockquote br],
      attributes: %w[style src href alt title target]
    )
  end
end
