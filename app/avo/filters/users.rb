# frozen_string_literal: true

module Avo::Filters::Users
  class Admin < Avo::Filters::BooleanFilter
    self.name = "User Type"

    def apply(_request, query, value)
      return query if value.blank?

      if value["admin"]
        query.where(admin: true)
      elsif value["non_admin"]
        query.where(admin: false)
      else
        query
      end
    end

    def options
      {
        admin: "Admins",
        non_admin: "Non-admins"
      }
    end
  end

  class Subscribed < Avo::Filters::BooleanFilter
    self.name = "Subscription"

    def apply(_request, query, value)
      return query if value.blank?

      if value["subscribed"]
        query.where(subscribed: true)
      elsif value["unsubscribed"]
        query.where(subscribed: false)
      else
        query
      end
    end

    def options
      {
        subscribed: "Subscribed",
        unsubscribed: "Unsubscribed"
      }
    end
  end

  class Name < Avo::Filters::TextFilter
    self.name = "Name"

    def apply(_request, query, value)
      return query if value.blank?

      query.where("name ILIKE ?", "%#{value}%")
    end
  end

  class Email < Avo::Filters::TextFilter
    self.name = "Email"

    def apply(_request, query, value)
      return query if value.blank?

      query.where("email ILIKE ?", "%#{value}%")
    end
  end

  class EducationalInstitute < Avo::Filters::TextFilter
    self.name = "Educational Institute"

    def apply(_request, query, value)
      return query if value.blank?

      query.where("educational_institute ILIKE ?", "%#{value}%")
    end
  end

  class Locale < Avo::Filters::TextFilter
    self.name = "Locale"

    def apply(_request, query, value)
      return query if value.blank?

      query.where("locale ILIKE ?", "%#{value}%")
    end
  end

  class Provider < Avo::Filters::TextFilter
    self.name = "Provider"

    def apply(_request, query, value)
      return query if value.blank?

      query.where("provider ILIKE ?", "%#{value}%")
    end
  end

  class Uid < Avo::Filters::TextFilter
    self.name = "UID"

    def apply(_request, query, value)
      return query if value.blank?

      query.where("uid ILIKE ?", "%#{value}%")
    end
  end

  class CurrentSignInIp < Avo::Filters::TextFilter
    self.name = "Current Sign In IP"

    def apply(_request, query, value)
      return query if value.blank?

      query.where("current_sign_in_ip ILIKE ?", "%#{value}%")
    end
  end

  class LastSignInIp < Avo::Filters::TextFilter
    self.name = "Last Sign In IP"

    def apply(_request, query, value)
      return query if value.blank?

      query.where("last_sign_in_ip ILIKE ?", "%#{value}%")
    end
  end

  class UnconfirmedEmail < Avo::Filters::TextFilter
    self.name = "Unconfirmed Email"

    def apply(_request, query, value)
      return query if value.blank?

      query.where("unconfirmed_email ILIKE ?", "%#{value}%")
    end
  end

  class Id < Avo::Filters::SelectFilter
    self.name = "ID Range"

    def options
      {
        "1-100" => "1-100",
        "101-500" => "101-500",
        "501-1000" => "501-1000",
        "1000+" => "1000+"
      }
    end

    def apply(_request, query, value)
      return query if value.blank?

      case value
      when "1-100"
        query.where(id: 1..100)
      when "101-500"
        query.where(id: 101..500)
      when "501-1000"
        query.where(id: 501..1000)
      when "1000+"
        query.where("id > ?", 1000)
      else
        query
      end
    end
  end

  class SignInCount < Avo::Filters::SelectFilter
    self.name = "Sign In Count"

    def options
      {
        "0" => "Never signed in",
        "1-5" => "1-5 times",
        "6-20" => "6-20 times",
        "21+" => "21+ times"
      }
    end

    def apply(_request, query, value)
      return query if value.blank?

      case value
      when "0"
        query.where(sign_in_count: 0)
      when "1-5"
        query.where(sign_in_count: 1..5)
      when "6-20"
        query.where(sign_in_count: 6..20)
      when "21+"
        query.where("sign_in_count > ?", 20)
      else
        query
      end
    end
  end

  class ProjectsCount < Avo::Filters::SelectFilter
    self.name = "Projects Count"

    def options
      {
        "0" => "No projects",
        "1-5" => "1-5 projects",
        "6-20" => "6-20 projects",
        "21+" => "21+ projects"
      }
    end

    def apply(_request, query, value)
      return query if value.blank?

      case value
      when "0"
        query.where(projects_count: 0)
      when "1-5"
        query.where(projects_count: 1..5)
      when "6-20"
        query.where(projects_count: 6..20)
      when "21+"
        query.where("projects_count > ?", 20)
      else
        query
      end
    end
  end

  class BaseDateFilter < Avo::Filters::SelectFilter
    OPTIONS = {
      "today" => "Today",
      "yesterday" => "Yesterday",
      "this_week" => "This week",
      "last_week" => "Last week",
      "this_month" => "This month",
      "last_month" => "Last month",
      "this_year" => "This year"
    }.freeze

    def options
      OPTIONS
    end

    def apply(_request, query, value)
      return query if value.blank?

      date_range = compute_date_range(value)
      return query unless date_range

      query.where(self.class::COLUMN => date_range)
    end

    DATE_RANGE_BUILDERS = {
      "today" => -> { Date.current.all_day },
      "yesterday" => -> { 1.day.ago.all_day },
      "this_week" => -> { Date.current.all_week },
      "last_week" => -> { 1.week.ago.all_week },
      "this_month" => -> { Date.current.all_month },
      "last_month" => -> { 1.month.ago.all_month },
      "this_year" => -> { Date.current.all_year }
    }.freeze

    def compute_date_range(value)
      DATE_RANGE_BUILDERS[value]&.call
    end
  end

  class CurrentSignInAt < BaseDateFilter
    self.name = "Current Sign In At"
    COLUMN = "current_sign_in_at"
  end

  class LastSignInAt < BaseDateFilter
    self.name = "Last Sign In At"
    COLUMN = "last_sign_in_at"
  end

  class ConfirmedAt < BaseDateFilter
    self.name = "Confirmed At"
    COLUMN = "confirmed_at"
  end

  class ConfirmationSentAt < BaseDateFilter
    self.name = "Confirmation Sent At"
    COLUMN = "confirmation_sent_at"
  end

  class CreatedAt < BaseDateFilter
    self.name = "Created At"
    COLUMN = "created_at"
  end

  class UpdatedAt < BaseDateFilter
    self.name = "Updated At"
    COLUMN = "updated_at"
  end
end
