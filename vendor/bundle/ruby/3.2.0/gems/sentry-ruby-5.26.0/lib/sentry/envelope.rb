# frozen_string_literal: true

module Sentry
  # @api private
  class Envelope
    attr_accessor :headers, :items

    def initialize(headers = {})
      @headers = headers
      @items = []
    end

    def add_item(headers, payload)
      @items << Item.new(headers, payload)
    end

    def item_types
      @items.map(&:type)
    end

    def event_id
      @headers[:event_id]
    end
  end
end

require_relative "envelope/item"
