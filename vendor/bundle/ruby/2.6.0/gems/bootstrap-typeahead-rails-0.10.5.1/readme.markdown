# Bootstrap Typeahead for Rails

[![Gem Version](https://badge.fury.io/rb/bootstrap-typeahead-rails.png)](http://badge.fury.io/rb/bootstrap-typeahead-rails)

[![endorse](https://api.coderwall.com/nerian/endorsecount.png)](https://coderwall.com/nerian)

bootstrap-typeahead-rails project integrates the official typeahead plugin with Rails 3 assets pipeline.

http://github.com/Nerian/bootstrap-typeahead-rails

https://github.com/twitter/typeahead.js/

## Rails > 3.1
Include bootstrap-typeahead-rails in Gemfile;

``` ruby
gem 'bootstrap-typeahead-rails'
```

or you can install from latest build;

``` ruby
gem 'bootstrap-typeahead-rails', :require => 'bootstrap-typeahead-rails',
                              :git => 'git://github.com/Nerian/bootstrap-typeahead-rails.git'
```

and run bundle install.

## Configuration

Add this line to `app/assets/javascripts/application.js`

``` javascript
//= require bootstrap-typeahead-rails
```

The official Typeahead do not include any styling for it. Nonetheless, you can add this line to `app/assets/stylesheets/application.css` and you will get a nice one. Or don't, and implement your own – instructions on https://github.com/twitter/typeahead.js/#look-and-feel.

``` javascript
*= require bootstrap-typeahead-rails
```

## Using bootstrap-typeahead-rails

See https://github.com/twitter/typeahead.js/#usage

## Questions? Bugs?

Bugs and improvements for the typehead plugin should go to https://github.com/twitter/typeahead.js/#usage. Bugs related to this gem should go to this project's issues list.

## License
Copyright (c) 2013 Gonzalo Rodríguez-Baltanás Díaz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
