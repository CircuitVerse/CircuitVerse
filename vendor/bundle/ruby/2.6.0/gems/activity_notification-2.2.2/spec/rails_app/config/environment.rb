# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Demo application uses Devise and Devise Token Auth
require 'devise'
require 'devise_token_auth'

# Initialize the Rails application.
Rails.application.initialize!

def silent_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
end

# Load database schema
if Rails.env.test? && ['mongodb', 'dynamodb'].exclude?(ENV['AN_TEST_DB'])
  silent_stdout do
    load "#{Rails.root}/db/schema.rb"
  end
end
