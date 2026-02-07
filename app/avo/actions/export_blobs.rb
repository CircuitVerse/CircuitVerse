# frozen_string_literal: true

class Avo::Actions::ExportBlobs < Avo::BaseAction
  self.name = "Export Blobs"
  self.message = "Export selected blobs to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false
  self.standalone = true

  def handle(**args)
    records = fetch_records(args)

    return error "No records to export" if records.empty?

    csv_data = generate_csv(records)
    filename = "active_storage_blobs_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    download csv_data, filename
    succeed "Exported #{records.count} blob#{'s' unless records.one?}"
  end

  private

    def fetch_records(args)
      fields = args[:fields] || {}

      if should_export_all?(fields, args[:query])
        ::ActiveStorage::Blob.includes(:attachments, :variant_records).to_a
      else
        extract_query_records(args[:query])
      end
    end

    def should_export_all?(fields, query)
      fields[:avo_selected_all] == "true" || query.blank? || query.empty?
    end

    def extract_query_records(query)
      query.respond_to?(:to_a) ? query.to_a : query
    end

    def generate_csv(records)
      CSV.generate(headers: true) do |csv|
        csv << csv_headers
        records.each { |record| csv << csv_row(record) }
      end
    end

    def csv_headers
      [
        "ID",
        "Key",
        "Filename",
        "Content Type",
        "Service Name",
        "Byte Size",
        "Byte Size (Human)",
        "Checksum",
        "Attachments Count",
        "Variant Records Count",
        "Metadata",
        "Created At"
      ]
    end

    def csv_row(record)
      [
        record.id,
        record.key,
        record.filename,
        record.content_type,
        record.service_name,
        record.byte_size,
        number_to_human_size(record.byte_size),
        record.checksum,
        record.attachments.count,
        record.variant_records.count,
        record.metadata&.to_json,
        record.created_at&.strftime("%Y-%m-%d %H:%M:%S")
      ]
    end

    def number_to_human_size(size)
      return "0 Bytes" if size.zero?

      units = %w[Bytes KB MB GB TB]
      exp = (Math.log(size) / Math.log(1024)).to_i
      exp = [exp, units.size - 1].min

      format(
        "%<size>.2f %<unit>s",
        size: size.to_f / (1024**exp),
        unit: units[exp]
      )
    end
end
