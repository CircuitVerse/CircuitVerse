module Playwright
  #
  # `Download` objects are dispatched by page via the [`event: Page.download`] event.
  #
  # All the downloaded files belonging to the browser context are deleted when the
  # browser context is closed.
  #
  # Download event is emitted once the download starts. Download path becomes available once download completes.
  #
  # ```python sync
  # # Start waiting for the download
  # with page.expect_download() as download_info:
  #     # Perform the action that initiates download
  #     page.get_by_text("Download file").click()
  # download = download_info.value
  #
  # # Wait for the download process to complete and save the downloaded file somewhere
  # download.save_as("/path/to/save/at/" + download.suggested_filename)
  # ```
  class Download < PlaywrightApi

    #
    # Cancels a download. Will not fail if the download is already finished or canceled.
    # Upon successful cancellations, `download.failure()` would resolve to `'canceled'`.
    def cancel
      wrap_impl(@impl.cancel)
    end

    #
    # Deletes the downloaded file. Will wait for the download to finish if necessary.
    def delete
      wrap_impl(@impl.delete)
    end

    #
    # Returns download error if any. Will wait for the download to finish if necessary.
    def failure
      wrap_impl(@impl.failure)
    end

    #
    # Get the page that the download belongs to.
    def page
      wrap_impl(@impl.page)
    end

    #
    # Returns path to the downloaded file for a successful download, or throws for a failed/canceled download. The method will wait for the download to finish if necessary. The method throws when connected remotely.
    #
    # Note that the download's file name is a random GUID, use [`method: Download.suggestedFilename`]
    # to get suggested file name.
    def path
      wrap_impl(@impl.path)
    end

    #
    # Copy the download to a user-specified path. It is safe to call this method while the download
    # is still in progress. Will wait for the download to finish if necessary.
    #
    # **Usage**
    #
    # ```python sync
    # download.save_as("/path/to/save/at/" + download.suggested_filename)
    # ```
    def save_as(path)
      wrap_impl(@impl.save_as(unwrap_impl(path)))
    end

    #
    # Returns suggested filename for this download. It is typically computed by the browser from the
    # [`Content-Disposition`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition) response header
    # or the `download` attribute. See the spec on [whatwg](https://html.spec.whatwg.org/#downloading-resources). Different
    # browsers can use different logic for computing it.
    def suggested_filename
      wrap_impl(@impl.suggested_filename)
    end

    #
    # Returns downloaded url.
    def url
      wrap_impl(@impl.url)
    end
  end
end
