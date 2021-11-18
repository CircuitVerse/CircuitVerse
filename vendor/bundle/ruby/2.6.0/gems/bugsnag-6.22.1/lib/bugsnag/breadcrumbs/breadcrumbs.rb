module Bugsnag::Breadcrumbs
  VALID_BREADCRUMB_TYPES = [
    ERROR_BREADCRUMB_TYPE = "error",
    MANUAL_BREADCRUMB_TYPE = "manual",
    NAVIGATION_BREADCRUMB_TYPE = "navigation",
    REQUEST_BREADCRUMB_TYPE = "request",
    PROCESS_BREADCRUMB_TYPE = "process",
    LOG_BREADCRUMB_TYPE = "log",
    USER_BREADCRUMB_TYPE = "user",
    STATE_BREADCRUMB_TYPE = "state"
  ].freeze
end
