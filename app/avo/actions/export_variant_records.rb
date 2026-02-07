# frozen_string_literal: true

class Avo::Actions::ExportVariantRecords < Avo::BaseAction
  self.name = "Export to CSV"
  self.visible = -> { true }
  self.standalone = true

  def handle(query:, **)
    require "csv"

    records = query.presence || ActiveStorage::VariantRecord.all
    record_count = records.size

    csv_data = generate_csv(records)

    download(csv_data, "variant_records_#{Time.current.to_i}.csv")

    succeed "Successfully exported #{record_count} variant record#{'s' unless record_count == 1}"
  end

  private

    def generate_csv(records)
      CSV.generate(headers: true) do |csv|
        csv << ["ID", "Blob ID", "Variation Digest"]

        records.each do |record|
          csv << [record.id, record.blob_id, record.variation_digest]
        end
      end
    end
end
