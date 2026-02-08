# frozen_string_literal: true

class Avo::Actions::ImportMailkickOptOuts < Avo::BaseAction
  self.name = "Import Opt-Outs"
  self.message = "Upload CSV file to import opt-outs"
  self.confirm_button_label = "Import"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false
  self.standalone = true

  def fields
    field :csv_file, as: :file, help: "CSV format: email, user_type, user_id, active, list, reason"
  end

  def handle(fields:, _current_user:, _resource:, **)
    csv_file = fields[:csv_file]

    return error "Please upload a CSV file" if csv_file.blank?

    result = process_csv(csv_file)
    display_result(result)
  rescue CSV::MalformedCSVError => e
    error "Invalid CSV file: #{e.message}"
  rescue StandardError => e
    error "Import failed: #{e.message}"
  end
  # rubocop:enable Metrics/AbcSize

  private

    def process_csv(csv_file)
      imported = 0
      errors = []

      CSV.parse(csv_file.read, headers: true) do |row|
        result = process_row(row)

        if result[:success]
          imported += 1
        else
          errors << result[:error]
        end
      end

      { imported: imported, errors: errors }
    end

    def process_row(row)
      email = row["email"]&.strip

      return { success: false, error: "Row #{row.line_number}: Email is required" } if email.blank?

      opt_out = find_or_initialize_opt_out(row, email)

      if opt_out.save
        { success: true }
      else
        error_msg = "Row #{row.line_number} (#{email}): #{opt_out.errors.full_messages.join(', ')}"
        { success: false, error: error_msg }
      end
    end

    def find_or_initialize_opt_out(row, email)
      opt_out = ::Mailkick::OptOut.find_or_initialize_by(
        email: email,
        list: row["list"]&.strip
      )

      opt_out.assign_attributes(
        user_type: row["user_type"]&.strip,
        user_id: row["user_id"]&.strip&.to_i,
        active: ActiveModel::Type::Boolean.new.cast(row["active"] || true),
        reason: row["reason"]&.strip
      )

      opt_out
    end

    def display_result(result)
      if result[:errors].any?
        error_preview = result[:errors].first(5).join("; ")
        error "Imported #{result[:imported]} opt-outs with #{result[:errors].count} errors: #{error_preview}"
      else
        succeed "Successfully imported #{result[:imported]} opt-outs"
      end
    end
end
