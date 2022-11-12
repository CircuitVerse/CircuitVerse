require "bugsnag/breadcrumbs/breadcrumbs"

module Bugsnag
  module BreadcrumbType
    ERROR = Bugsnag::Breadcrumbs::ERROR_BREADCRUMB_TYPE
    LOG = Bugsnag::Breadcrumbs::LOG_BREADCRUMB_TYPE
    MANUAL = Bugsnag::Breadcrumbs::MANUAL_BREADCRUMB_TYPE
    NAVIGATION = Bugsnag::Breadcrumbs::NAVIGATION_BREADCRUMB_TYPE
    PROCESS = Bugsnag::Breadcrumbs::PROCESS_BREADCRUMB_TYPE
    REQUEST = Bugsnag::Breadcrumbs::REQUEST_BREADCRUMB_TYPE
    STATE = Bugsnag::Breadcrumbs::STATE_BREADCRUMB_TYPE
    USER = Bugsnag::Breadcrumbs::USER_BREADCRUMB_TYPE
  end
end
