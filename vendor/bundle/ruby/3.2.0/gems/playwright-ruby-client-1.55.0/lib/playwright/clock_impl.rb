module Playwright
  define_api_implementation :ClockImpl do
    def initialize(browser_context)
      @browser_context = browser_context
    end

    def install(time: nil)
      if time
        @browser_context.send(:clock_install, parse_time(time))
      else
        @browser_context.send(:clock_install, {})
      end
    end

    def fast_forward(ticks)
      @browser_context.send(:clock_fast_forward, parse_ticks(ticks))
    end

    def pause_at(time)
      @browser_context.send(:clock_pause_at, parse_time(time))
    end

    def resume
      @browser_context.send(:clock_resume)
    end

    def run_for(ticks)
      @browser_context.send(:clock_run_for, parse_ticks(ticks))
    end

    def set_fixed_time(time)
      @browser_context.send(:clock_set_fixed_time, parse_time(time))
    end

    def set_system_time(time)
      @browser_context.send(:clock_set_system_time, parse_time(time))
    end

    private def parse_time(time)
      case time
      when Integer
        { timeNumber: time }
      when String
        { timeString: time }
      when DateTime
        { timeNumber: time.to_time.to_i * 1000 }
      else
        if time.respond_to?(:utc)
          { timeNumber: time.utc.to_i * 1000 }
        else
          raise ArgumentError.new('time must be either integer, string or a Time object')
        end
      end
    end

    private def parse_ticks(ticks)
      case ticks
      when Integer
        { ticksNumber: ticks }
      when String
        { ticksString: ticks }
      else
        raise ArgumentError.new('ticks must be either integer or string')
      end
    end
  end
end
