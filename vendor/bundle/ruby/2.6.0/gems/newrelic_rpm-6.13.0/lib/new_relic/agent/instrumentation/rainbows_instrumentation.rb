# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  @name = :rainbows

  depends_on do
    defined?(::Rainbows) && defined?(::Rainbows::HttpServer)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Rainbows instrumentation'
    ::NewRelic::Agent.logger.info 'Detected Rainbows, please see additional documentation: https://newrelic.com/docs/troubleshooting/im-using-unicorn-and-i-dont-see-any-data'
  end

  executes do
    Rainbows::HttpServer.class_eval do
      old_worker_loop = instance_method(:worker_loop)
      define_method(:worker_loop) do |worker|
        NewRelic::Agent.after_fork(:force_reconnect => true)
        old_worker_loop.bind(self).call(worker)
      end
    end
  end
end
