module Bugsnag
  class EndpointConfiguration
    attr_reader :notify
    attr_reader :sessions

    def initialize(notify, sessions)
      @notify = notify
      @sessions = sessions
    end
  end
end
