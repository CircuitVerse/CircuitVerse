module Playwright
  define_api_implementation :DownloadImpl do
    def initialize(page:, url:, suggested_filename:, artifact:)
      @page = page
      @url = url
      @suggested_filename = suggested_filename
      @artifact = artifact
    end

    attr_reader :page, :url, :suggested_filename

    def delete
      @artifact.delete
    end

    def failure
      @artifact.failure
    end

    def path
      @artifact.path_after_finished
    end

    def save_as(path)
      @artifact.save_as(path)
    end

    def cancel
      @artifact.cancel
    end
  end
end
