module Playwright
  define_channel_owner :Worker do
    attr_writer :context, :page

    private def after_initialize
      @channel.once('close', ->(_) { on_close })
    end

    private def on_close
      @page&.send(:remove_worker, self)
      @context&.send(:remove_service_worker, self)
      emit(Events::Worker::Close, self)
    end

    def url
      @initializer['url']
    end

    def evaluate(expression, arg: nil)
      JavaScript::Expression.new(expression, arg).evaluate(@channel)
    end

    def evaluate_handle(expression, arg: nil)
      JavaScript::Expression.new(expression, arg).evaluate_handle(@channel)
    end
  end
end
