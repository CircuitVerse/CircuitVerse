## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Tests

Because of the nature of AJAX file uploads and certain browser restrictions, we could not simply create unit tests (using qunit or jasmine)
to test the file upload functionality of remotipart (since the browsers running those test suites won't allow us to set the target of a file
upload input using javascript). So, instead we created a demo Rails app using remotipart with all remotipart functionality tested using RSpec and Capybara.

* [Demo Rails App with
  Tests](https://github.com/JangoSteve/Rails-jQuery-Demo/tree/remotipart)
* [Tests](https://github.com/JangoSteve/Rails-jQuery-Demo/blob/remotipart/spec/features/comments_spec.rb)

To run tests:

Clone the remotipart branch of the demo app

```
git clone -b remotipart git://github.com/JangoSteve/Rails-jQuery-Demo.git
```

Install the dependencies

```
bundle install
```

Run the tests

```
bundle exec rspec spec/
```

If you need to test your own changes to remotipart, just update the Gemfile with your own fork/branch of remotipart:

```
gem 'remotipart', :git => 'git://github.com/MY_FORK/remotipart.git', :branch => 'MY_BRANCH'
```

To save time, you can also just bundle remotipart from your current
local machine / filesystem without having to commit your changes
or push them remotely:

```
gem 'remotipart', :path => '../remotipart'
```
