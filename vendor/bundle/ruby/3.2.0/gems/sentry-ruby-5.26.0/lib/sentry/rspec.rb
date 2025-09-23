# frozen_string_literal: true

RSpec::Matchers.define :include_sentry_event do |event_message = "", **opts|
  match do |sentry_events|
    @expected_exception = expected_exception(**opts)
    @context = context(**opts)
    @tags = tags(**opts)

    @expected_event = expected_event(event_message)
    @matched_event = find_matched_event(event_message, sentry_events)

    return false unless @matched_event

    [verify_context(), verify_tags()].all?
  end

  chain :with_context do |context|
    @context = context
  end

  chain :with_tags do |tags|
    @tags = tags
  end

  failure_message do |sentry_events|
    info = ["Failed to find event matching:\n"]
    info << "  message: #{@expected_event.message.inspect}"
    info << "  exception: #{@expected_exception.inspect}"
    info << "  context: #{@context.inspect}"
    info << "  tags: #{@tags.inspect}"
    info << "\n"
    info << "Captured events:\n"
    info << dump_events(sentry_events)
    info.join("\n")
  end

  def expected_event(event_message)
    if @expected_exception
      Sentry.get_current_client.event_from_exception(@expected_exception)
    else
      Sentry.get_current_client.event_from_message(event_message)
    end
  end

  def expected_exception(**opts)
    opts[:exception].new(opts[:message]) if opts[:exception]
  end

  def context(**opts)
    opts.fetch(:context, @context || {})
  end

  def tags(**opts)
    opts.fetch(:tags, @tags || {})
  end

  def find_matched_event(event_message, sentry_events)
    @matched_event ||= sentry_events
      .find { |event|
        if @expected_exception
          # Is it OK that we only compare the first exception?
          event_exception = event.exception.values.first
          expected_event_exception = @expected_event.exception.values.first

          event_exception.type == expected_event_exception.type && event_exception.value == expected_event_exception.value
        else
          event.message == @expected_event.message
        end
      }
  end

  def dump_events(sentry_events)
    sentry_events.map(&Kernel.method(:Hash)).map do |hash|
      hash.select { |k, _| [:message, :contexts, :tags, :exception].include?(k) }
    end.map do |hash|
      JSON.pretty_generate(hash)
    end.join("\n\n")
  end

  def verify_context
    return true if @context.empty?

    @matched_event.contexts.any? { |key, value| value == @context[key] }
  end

  def verify_tags
    return true if @tags.empty?

    @tags.all? { |key, value| @matched_event.tags.include?(key) && @matched_event.tags[key] == value }
  end
end
