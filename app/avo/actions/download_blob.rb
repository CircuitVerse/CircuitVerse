# frozen_string_literal: true

class Avo::Actions::DownloadBlob < Avo::BaseAction
  self.name = "Download File"

  # Only show action when records are selected
  self.visible = lambda {
    if view == :index
      params[:selected_records].present?
    else
      true
    end
  }

  self.standalone = false

  # rubocop:disable Lint/UnusedMethodArgument
  def handle(query:, fields:, current_user:, resource:, **args)
    blobs = query

    if blobs.empty?
      error "Please select at least one file to download"
      return
    end

    blob = blobs.first

    if blob.is_a?(ActiveStorage::Blob)
      # Use the blob's service URL directly
      url = blob.url(disposition: "attachment")

      redirect_to url, allow_other_host: true
      succeed "Downloading #{blob.filename}"
    else
      error "Invalid file"
    end
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
