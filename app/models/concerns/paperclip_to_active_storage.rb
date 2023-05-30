# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Style/RedundantInterpolation

module PaperclipToActiveStorage
  def pap_with_as(attribute, pap)
    has_one_attached attribute
    has_attached_file attribute, pap

    # Copied from Active Storage
    define_method "active_storage_#{attribute}=" do |attachable|
      attachment_changes["#{attribute}"] = if attachable.nil?
        ActiveStorage::Attached::Changes::DeleteOne.new("#{attribute}", self)
      else
        ActiveStorage::Attached::Changes::CreateOne.new("#{attribute}", self, attachable)
      end
    end
    # Copied from Paperclip
    define_method "paperclip_#{attribute}=" do |attachable|
      send(attribute).assign(attachable)
    end
    define_method "#{attribute}=" do |attachable|
      public_send("active_storage_#{attribute}=", attachable)
      public_send("paperclip_#{attribute}=", attachable)
    end
  end
end

# rubocop:enable Metrics/MethodLength
# rubocop:enable Style/RedundantInterpolation
