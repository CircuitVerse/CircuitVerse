### 0.6.0 - 2019-04-11

* enhancements
  * experimental support for Webpacker (@rossta, @pedantic-git)
  * allow cache override (@omnibs)
  * support recent rubies (@grzuy)

### 0.5.5 - 2017-05-01

* bug fixes
  * Ensure middleware can handle assets when a separate asset host, e.g. a CDN,
    is configured

### 0.5.4 - 2017-02-02

* bug fixes
  * Fix cache name for proper cache deletion in activation callback of serviceworker template

### 0.5.3 - 2017-01-11

* bug fixes
  * Fix javascript variable name error in serviceworker template (@amelzer)

### 0.5.2 - 2017-01-07

* enhancements
  * Enable generated serviceworker.js with improved fetch logic
* bug fixes
  * Omit application.js from generated serviceworker.js to prevent circular
    sprockets requires

### 0.5.1 - 2016-11-17

* enhancements
  * Add support for Rails 3
* bug fixes
  * Fix syntax error in generated serviceworker.js
  * Remove duplicate line in generated manifest.json (@brandonhilkert)

### 0.5.0 - 2016-11-10

* enhancements
  * Convert railtie to Rails engine
  * Extend install generator to add offline page and starter icons for generated web app manifest
  * Install serviceworker and manifest as .erb files

### 0.4.0 - 2016-11-09

* enhancements
  * Add install generator to insert code snippets and add default serviceworker
    and companion scripts, web app manifest, and Rails initializer

### 0.3.1 - 2016-05-03

* enhancements
  * add CHANGELOG
* bug fixes
  * ensure railtie adds middleware to stack after config initializers are loaded

### 0.3.0 - 2016-05-02

* enhancements
  * new route matching behavior; similar to Rails-routing style and Rack::Router
  * add to Travis-CI builds

### 0.2.0 - 2016-04-25

* enhancements
  * routes are now configurable instead of a single-hardcoded path
  * support custom headers
  * extract Route and Router classes

### 0.1.0 - 2016-04-23

* initial release
