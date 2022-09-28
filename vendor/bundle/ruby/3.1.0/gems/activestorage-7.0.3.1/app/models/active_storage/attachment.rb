# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

# Attachments associate records with blobs. Usually that's a one record-many blobs relationship,
# but it is possible to associate many different records with the same blob. A foreign-key constraint
# on the attachments table prevents blobs from being purged if they’re still attached to any records.
#
# Attachments also have access to all methods from {ActiveStorage::Blob}[rdoc-ref:ActiveStorage::Blob].
#
# If you wish to preload attachments or blobs, you can use these scopes:
#
#   # preloads attachments, their corresponding blobs, and variant records (if using `ActiveStorage.track_variants`)
#   User.all.with_attached_avatars
#
#   # preloads blobs and variant records (if using `ActiveStorage.track_variants`)
#   User.first.avatars.with_all_variant_records
class ActiveStorage::Attachment < ActiveStorage::Record
  self.table_name = "active_storage_attachments"

  belongs_to :record, polymorphic: true, touch: true
  belongs_to :blob, class_name: "ActiveStorage::Blob", autosave: true

  delegate_missing_to :blob
  delegate :signed_id, to: :blob

  after_create_commit :mirror_blob_later, :analyze_blob_later
  after_destroy_commit :purge_dependent_blob_later

  scope :with_all_variant_records, -> { includes(blob: :variant_records) }

  # Synchronously deletes the attachment and {purges the blob}[rdoc-ref:ActiveStorage::Blob#purge].
  def purge
    transaction do
      delete
      record.touch if record&.persisted?
    end
    blob&.purge
  end

  # Deletes the attachment and {enqueues a background job}[rdoc-ref:ActiveStorage::Blob#purge_later] to purge the blob.
  def purge_later
    transaction do
      delete
      record.touch if record&.persisted?
    end
    blob&.purge_later
  end

  # Returns an ActiveStorage::Variant or ActiveStorage::VariantWithRecord
  # instance for the attachment with the set of +transformations+ provided.
  # See ActiveStorage::Blob::Representable#variant for more information.
  #
  # Raises an +ArgumentError+ if +transformations+ is a +Symbol+ which is an
  # unknown pre-defined variant of the attachment.
  def variant(transformations)
    case transformations
    when Symbol
      variant_name = transformations
      transformations = variants.fetch(variant_name) do
        record_model_name = record.to_model.model_name.name
        raise ArgumentError, "Cannot find variant :#{variant_name} for #{record_model_name}##{name}"
      end
    end

    blob.variant(transformations)
  end

  private
    def analyze_blob_later
      blob.analyze_later unless blob.analyzed?
    end

    def mirror_blob_later
      blob.mirror_later
    end

    def purge_dependent_blob_later
      blob&.purge_later if dependent == :purge_later
    end

    def dependent
      record.attachment_reflections[name]&.options&.fetch(:dependent, nil)
    end

    def variants
      record.attachment_reflections[name]&.variants
    end
end

ActiveSupport.run_load_hooks :active_storage_attachment, ActiveStorage::Attachment
