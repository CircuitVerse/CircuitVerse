# frozen_string_literal: true

module OrganizationsHelper
  MEMBER_DISPLAY_CAP = 1000
  def org_member_sort_link(column, label, organization)
    new_direction, icon = org_sort_state(column)

    link_to members_organization_path(organization, sort: column, direction: new_direction),
            class: "org-sort-link d-inline-flex align-items-center gap-1 text-decoration-none" do
      safe_join([
                  content_tag(:span, label),
                  content_tag(:i, "", class: "fa #{icon} org-sort-icon", "aria-hidden": true)
                ])
    end
  end

  def capped_member_count(count, i18n_key)
    if count.to_i > MEMBER_DISPLAY_CAP
      t("#{i18n_key}_capped", count: MEMBER_DISPLAY_CAP)
    else
      t(i18n_key, count: count)
    end
  end

  private

    def org_sort_state(column)
      current_column = params[:sort].presence_in(%w[name role created_at]) || "role"
      current_direction = params[:direction].presence_in(%w[asc desc]) || "asc"

      return %w[asc fa-sort] unless current_column == column

      if current_direction == "asc"
        %w[desc fa-sort-up]
      else
        %w[asc fa-sort-down]
      end
    end
end
