# frozen_string_literal: true

module UserHelper
  def profile_picture_url_thumb(user)
    if user.profile_picture.attached?
      url_for(user.profile_picture.variant(resize_to_limit: [100, 100]))
    else
      "/img/default.png"
    end
  end
  def profile_picture_url_medium(user)
    if user.profile_picture.attached?
      url_for(user.profile_picture.variant(resize_to_limit: [205, 240]))
    else
      "/img/default.png"
    end
  end
end
