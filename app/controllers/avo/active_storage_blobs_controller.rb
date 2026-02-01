# frozen_string_literal: true

class Avo::ActiveStorageBlobsController < Avo::ResourcesController
  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :block_new_creation, only: %i[new create]
  # rubocop:enable Rails/LexicallyScopedActionFilter

  private

    def block_new_creation
      # rubocop:disable Rails/I18nLocaleTexts
      flash[:alert] = "Blobs are created automatically when files are uploaded. Cannot create manually."
      # rubocop:enable Rails/I18nLocaleTexts
      redirect_to "/admin2/resources/active_storage_blobs"
    end
end
