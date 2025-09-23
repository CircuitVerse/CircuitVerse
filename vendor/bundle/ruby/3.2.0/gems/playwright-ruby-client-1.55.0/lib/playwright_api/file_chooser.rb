module Playwright
  #
  # `FileChooser` objects are dispatched by the page in the [`event: Page.fileChooser`] event.
  #
  # ```python sync
  # with page.expect_file_chooser() as fc_info:
  #     page.get_by_text("Upload file").click()
  # file_chooser = fc_info.value
  # file_chooser.set_files("myfile.pdf")
  # ```
  class FileChooser < PlaywrightApi

    #
    # Returns input element associated with this file chooser.
    def element
      wrap_impl(@impl.element)
    end

    #
    # Returns whether this file chooser accepts multiple files.
    def multiple?
      wrap_impl(@impl.multiple?)
    end

    #
    # Returns page this file chooser belongs to.
    def page
      wrap_impl(@impl.page)
    end

    #
    # Sets the value of the file input this chooser is associated with. If some of the `filePaths` are relative paths, then
    # they are resolved relative to the current working directory. For empty array, clears the selected files.
    def set_files(files, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.set_files(unwrap_impl(files), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end
    alias_method :files=, :set_files
  end
end
