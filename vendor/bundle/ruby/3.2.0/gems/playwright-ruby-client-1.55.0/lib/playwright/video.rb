module Playwright
  class Video
    def initialize(page)
      @page = page
      @artifact = Concurrent::Promises.resolvable_future
      if @page.closed?
        on_page_closed
      else
        page.once('close', -> { on_page_closed })
      end
    end

    private def on_page_closed
      unless @artifact.resolved?
        @artifact.reject('Page closed')
      end
    end

    # called only from Page#on_video via send(:set_artifact, artifact)
    private def set_artifact(artifact)
      @artifact.fulfill(artifact)
    end

    def path
      if @page.send(:remote_connection?)
        raise 'Path is not available when using browserType.connect(). Use save_as() to save a local copy.'
      end
      wait_for_artifact_and do |artifact|
        artifact.absolute_path
      end
    end

    def save_as(path)
      wait_for_artifact_and do |artifact|
        artifact.save_as(path)
      end
    end

    def delete
      wait_for_artifact_and do |artifact|
        artifact.delete
      end
    end

    private def wait_for_artifact_and(&block)
      artifact = @artifact.value!
      unless artifact
        raise 'Page did not produce any video frames'
      end

      block.call(artifact)
    end
  end
end
