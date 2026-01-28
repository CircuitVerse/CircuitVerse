
# Module to sanitize UTF-8 attributes
module Utf8Sanitizer
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_utf8_attributes
  end

  private

  def sanitize_utf8_attributes
    attributes.each do |key, value|
      next unless value.is_a?(String)

      self[key] = value.scrub("")
    end
  end
end

# Patch Commontator classes
Rails.application.config.to_prepare do
  # Patch ApplicationController to handle nested Project routes
  Commontator::ApplicationController.class_eval do
    def commontable_url
      if @commontator_thread.commontable.is_a?(Project)
        main_app.user_project_url(@commontator_thread.commontable.author, @commontator_thread.commontable)
      else
        main_app.polymorphic_url(@commontator_thread.commontable)
      end
    end
  end

  # Patch models to sanitize UTF-8
  Commontator::Comment.include(Utf8Sanitizer)
  Commontator::Thread.include(Utf8Sanitizer)
end
