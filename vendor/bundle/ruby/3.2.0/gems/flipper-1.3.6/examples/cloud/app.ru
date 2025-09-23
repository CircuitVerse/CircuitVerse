# Usage (from the repo root):
#   env FLIPPER_CLOUD_TOKEN=<token> FLIPPER_CLOUD_SYNC_SECRET=<secret> bundle exec rackup examples/cloud/app.ru -p 9999
#   http://localhost:9999/

require 'bundler/setup'
require 'flipper/cloud'

Flipper.configure do |config|
  config.default { Flipper::Cloud.new }
end

run Flipper::Cloud.app
