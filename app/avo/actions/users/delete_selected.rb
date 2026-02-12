# frozen_string_literal: true

class Avo::Actions::Users::DeleteSelected < Avo::BaseAction
  self.name = "Delete Selected"
  self.message = "Are you sure you want to permanently delete the selected users?"
  self.confirm_button_label = "Delete"
  self.cancel_button_label = "Cancel"

  def handle(**args)
    records = fetch_records(args)
    current_user = args[:current_user]

    return error "No users selected to delete" if records.empty?

    result = perform_deletions(records, current_user)

    if result[:destroyed].zero?
      error "No users were deleted"
    else
      msg = "Deleted #{result[:destroyed]} #{'user'.pluralize(result[:destroyed])}"
      msg += " (#{result[:skipped]} skipped: cannot delete yourself)" if result[:skipped].positive?
      msg += " (#{result[:failed]} failed)" if result[:failed].positive?
      succeed msg
    end
  end

  private

    def fetch_records(args)
      query = args[:query]
      return [] if query.blank? || (query.respond_to?(:empty?) && query.empty?)

      query.respond_to?(:to_a) ? query.to_a : query
    end

    def perform_deletions(records, current_user)
      destroyed = 0
      skipped = 0
      failed = 0

      records.each do |record|
        if record == current_user
          skipped += 1
          next
        end

        begin
          destroyed += 1 if record.destroy
        rescue StandardError
          failed += 1
        end
      end

      { destroyed: destroyed, skipped: skipped, failed: failed }
    end
end
