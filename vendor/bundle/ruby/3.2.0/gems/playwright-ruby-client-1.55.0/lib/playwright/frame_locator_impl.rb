require_relative './locator_utils'

module Playwright
  define_api_implementation :FrameLocatorImpl do
    include LocatorUtils

    def initialize(frame:, frame_selector:)
      @frame = frame
      @frame_selector = frame_selector
    end

    private def _timeout(timeout)
      @frame.send(:_timeout, timeout)
    end

    def locator(
      selector,
      has: nil,
      hasNot: nil,
      hasNotText: nil,
      hasText: nil)
      LocatorImpl.new(
        frame: @frame,
        selector: "#{@frame_selector} >> internal:control=enter-frame >> #{selector}",
        has: has,
        hasNot: hasNot,
        hasNotText: hasNotText,
        hasText: hasText)
    end

    def owner
      LocatorImpl.new(
        frame: @frame,
        selector: @frame_selector,
      )
    end

    def frame_locator(selector)
      FrameLocatorImpl.new(
        frame: @frame,
        frame_selector: "#{@frame_selector} >> internal:control=enter-frame >> #{selector}",
      )
    end

    def first
      FrameLocatorImpl.new(
        frame: @frame,
        frame_selector: "#{@frame_selector} >> nth=0",
      )
    end

    def last
      FrameLocatorImpl.new(
        frame: @frame,
        frame_selector: "#{@frame_selector} >> nth=-1",
      )
    end

    def nth(index)
      FrameLocatorImpl.new(
        frame: @frame,
        frame_selector: "#{@frame_selector} >> nth=#{index}",
      )
    end
  end
end
