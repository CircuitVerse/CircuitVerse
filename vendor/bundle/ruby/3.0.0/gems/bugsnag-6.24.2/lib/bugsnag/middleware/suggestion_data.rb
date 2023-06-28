module Bugsnag::Middleware
  ##
  # Attaches any "Did you mean?" suggestions to the report
  class SuggestionData

    CAPTURE_REGEX = /Did you mean\?([\s\S]+)$/
    DELIMITER = "\n"

    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      matches = []
      report.raw_exceptions.each do |exception|
        match = CAPTURE_REGEX.match(exception.message)
        next unless match

        suggestions = match.captures[0].split(DELIMITER)
        matches.concat suggestions.map{ |suggestion| suggestion.strip }
      end

      if matches.size == 1
        report.add_tab(:error, {:suggestion => matches.first})
      elsif matches.size > 1
        report.add_tab(:error, {:suggestions => matches})
      end

      @bugsnag.call(report)
    end
  end
end
