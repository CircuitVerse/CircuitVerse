require "bugsnag/report"

module Bugsnag
  # For now Event is just an alias of Report. This points to the same object so
  # any changes to Report will also affect Event
  Event = Report
end
