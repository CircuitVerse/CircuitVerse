module Playwright
  define_api_implementation :ConsoleMessageImpl do
    def initialize(event)
      @event = event
    end

    def page
      @page ||= ChannelOwners::Page.from_nullable(@event['page'])
    end

    def type
      @event['type']
    end

    def text
      @event['text']
    end

    def args
      @event['args']&.map do |arg|
        ChannelOwner.from(arg)
      end
    end

    def location
      @event['location']
    end
  end
end
