module Bugsnag::Utility
  ##
  # A container class with a maximum size, that removes oldest items as required.
  #
  # @api private
  class CircularBuffer
    include Enumerable

    # @return [Integer] the current maximum allowable number of items
    attr_reader :max_items

    ##
    # @param max_items [Integer] the initial maximum number of items
    def initialize(max_items = 25)
      @max_items = max_items
      @buffer = []
    end

    ##
    # Adds an item to the circular buffer
    #
    # If this causes the buffer to exceed its maximum items, the oldest item will be removed
    #
    # @param item [Object] the item to add to the buffer
    # @return [self] returns itself to allow method chaining
    def <<(item)
      @buffer << item
      trim_buffer
      self
    end

    ##
    # Iterates over the buffer
    #
    # @yield [Object] sequentially gives stored items to the block
    def each(&block)
      @buffer.each(&block)
    end

    ##
    # Sets the maximum allowable number of items
    #
    # If the current number of items exceeds the new maximum, oldest items will be removed
    # until this is no longer the case
    #
    # @param new_max_items [Integer] the new allowed item maximum
    def max_items=(new_max_items)
      @max_items = new_max_items
      trim_buffer
    end

    private

    ##
    # Trims the buffer down to the current maximum allowable item number
    def trim_buffer
      trim_size = @buffer.size - @max_items
      trim_size = 0 if trim_size < 0
      @buffer.shift(trim_size)
    end
  end
end
