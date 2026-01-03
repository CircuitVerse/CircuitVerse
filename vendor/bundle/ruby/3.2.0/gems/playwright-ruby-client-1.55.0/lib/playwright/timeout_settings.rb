module Playwright
  class TimeoutSettings
    DEFAULT_TIMEOUT = 30000
    DEFAULT_LAUNCH_TIMEOUT = 180000 # 3 minutes

    def initialize(parent = nil)
      @parent = parent
    end

    attr_writer :default_timeout, :default_navigation_timeout

    def navigation_timeout(timeout_override = nil)
      timeout_override || @default_navigation_timeout || @default_timeout || @parent&.navigation_timeout || DEFAULT_TIMEOUT
    end

    def timeout(timeout_override = nil)
      timeout_override || @default_timeout || @parent&.timeout || DEFAULT_TIMEOUT
    end

    def launch_timeout(timeout_override = nil)
      timeout_override || @default_timeout || @parent&.launch_timeout || DEFAULT_LAUNCH_TIMEOUT
    end
  end
end
