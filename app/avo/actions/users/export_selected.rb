# frozen_string_literal: true

require "csv"

class Avo::Actions::Users::ExportSelected < Avo::BaseAction
  self.name = "Export Selected Users"
  self.message = "Export selected users to CSV"
  self.confirm_button_label = "Export"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(**args)
    records = fetch_records(args)

    return error "No records selected to export" if records.empty?

    csv_data = generate_csv(records)
    filename = "users_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    download csv_data, filename
    succeed "Exported #{records.count} #{'user'.pluralize(records.count)}"
  end

  private

    def fetch_records(args)
      query = args[:query]
      extract_query_records(query)
    end

    def extract_query_records(query)
      return [] if query.blank? || (query.respond_to?(:empty?) && query.empty?)

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
        "ID", "Name", "Email", "Admin", "Subscribed", "Country",
        "Educational Institute", "Locale", "Provider", "UID",
        "Sign In Count", "Current Sign In At", "Last Sign In At",
        "Current Sign In IP", "Last Sign In IP", "Confirmed At",
        "Confirmation Sent At", "Unconfirmed Email", "Projects Count",
        "Created At", "Updated At"
      ]
    end

    def row_fields
      %i[
        id name email admin subscribed country educational_institute locale provider uid
        sign_in_count current_sign_in_at last_sign_in_at current_sign_in_ip last_sign_in_ip
        confirmed_at confirmation_sent_at unconfirmed_email projects_count created_at updated_at
      ].freeze
    end

    def csv_row(record)
      row_fields.map { |f| format_field(record, f) }
    end

    def format_dt(value)
      value&.strftime("%Y-%m-%d %H:%M:%S")
    end

    def format_field(record, field)
      case field
      when :current_sign_in_at, :last_sign_in_at, :confirmed_at, :confirmation_sent_at, :created_at, :updated_at
        format_dt(record.public_send(field))
      else
        record.public_send(field)
      end
    end
end
