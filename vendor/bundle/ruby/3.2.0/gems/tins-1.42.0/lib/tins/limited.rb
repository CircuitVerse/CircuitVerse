require 'thread'

module Tins
  class Limited
    # Create a Limited instance, that runs _maximum_ threads at most.
    def initialize(maximum, name: nil)
      @maximum  = Integer(maximum)
      raise ArgumentError, "maximum < 1" if @maximum < 1
      @mutex    = Mutex.new
      @continue = ConditionVariable.new
      @name     = name
      @count    = 0
      @tg       = ThreadGroup.new
    end

    # The maximum number of worker threads.
    attr_reader :maximum

    # Execute _maximum_ number of threads in parallel.
    def execute(&block)
      @tasks or raise ArgumentError, "start processing first"
      @tasks << block
    end

    def process
      @tasks    = Queue.new
      @executor = create_executor
      @executor.name = @name if @name
      catch :stop do
        loop do
          yield self
        end
      ensure
        wait until done?
        @executor.kill
      end
    end

    def stop
      throw :stop
    end

    private

    def done?
      @tasks.empty? && @tg.list.empty?
    end

    def wait
      @tg.list.each(&:join)
    end

    def create_executor
      Thread.new do
        @mutex.synchronize do
          loop do
            if @count < @maximum
              task = @tasks.pop
              @count += 1
              Thread.new do
                @tg.add Thread.current
                task.(Thread.current)
              ensure
                @count -= 1
                @continue.signal
              end
            else
              @continue.wait(@mutex)
            end
          end
        end
      end
    end
  end
end

require 'tins/alias'
