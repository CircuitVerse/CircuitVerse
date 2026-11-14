# frozen_string_literal: true

module UsersCircuitverseHelper
  def get_priority_countries
    priority_countries = ["IN"]
    geo_country = Geocoder.search(request.remote_ip).first&.country
    priority_countries.prepend(geo_country) if priority_countries.exclude?(geo_country) && !geo_country.nil?
    priority_countries
  end

  def user_profile_picture(attachment)
    if profile_picture_attached?(attachment)
      attachment
    else
      image_path("/images/thumb/Default.jpg")
    end
  end

  private

    def profile_picture_attached?(attachment)
      return false if attachment.blank?

      if attachment.respond_to?(:attached?)
        attachment.attached? && attachment.attachment&.persisted?
      elsif attachment.respond_to?(:persisted?)
        attachment.persisted?
      else
        false
      end
    end
end
