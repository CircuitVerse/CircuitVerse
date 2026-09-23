# frozen_string_literal: true

module OrganizationsHelper
  MEMBER_DISPLAY_CAP = 1000

  def capped_member_count(count, i18n_key)
    if count.to_i > MEMBER_DISPLAY_CAP
      t("#{i18n_key}_capped", count: MEMBER_DISPLAY_CAP)
    else
      t(i18n_key, count: count)
    end
  end
end
