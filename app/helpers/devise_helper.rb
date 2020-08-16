# frozen_string_literal: true

module DeviseHelper
  def devise_error_messages!
     resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
  end
end
