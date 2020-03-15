# jquery-ui-rails

[![Build Status](https://secure.travis-ci.org/joliss/jquery-ui-rails.png?branch=master)](http://travis-ci.org/joliss/jquery-ui-rails)
[![Dependency Status](https://gemnasium.com/joliss/jquery-ui-rails.png)](https://gemnasium.com/joliss/jquery-ui-rails)

This gem packages the jQuery UI assets (JavaScripts, stylesheets, and
images) for the Rails [asset
pipeline](http://guides.rubyonrails.org/asset_pipeline.html), so you never have
to download a custom package through the [web
interface](http://jqueryui.com/download) again.

See [VERSIONS.md](VERSIONS.md) to see which versions of jquery-ui-rails bundle
which versions of jQuery UI.

Warning: This gem is incompatible with the `jquery-rails` gem before version
3.0.0! Strange things will happen if you use an earlier `jquery-rails`
version. Run `bundle list` to ensure that you either aren't using
`jquery-rails`, or at least version 3.0.0 of `jquery-rails`.

## Usage

In your Gemfile, add:

```ruby
gem 'jquery-ui-rails'
```

## Require Everything

To require all jQuery UI modules, add the following to your application.js:

```javascript
//= require jquery-ui
```

Also add the jQuery UI CSS to your application.css:

```css
/*
 *= require jquery-ui
 */
```

### Warning:
Due to directory structure changes between jQuery UI 1.10, 1.11, and 1.12,
if you use version is lower than 6.0, you will have to use a different naming
for the files to require, please check following links for more information:
[for 5.0 users](https://github.com/joliss/jquery-ui-rails/blob/v5.0.5/README.md),
[for 4.2 users](https://github.com/joliss/jquery-ui-rails/blob/v4.2.1/README.md).

All images required by jQuery UI are automatically served through the asset
pipeline, so you are good to go! For example, this code will add a
[datepicker](http://jqueryui.com/demos/datepicker/):

```javascript
$(function() {
  $('.datepicker').datepicker();
});
```

## Require Specific Modules

The jQuery UI code weighs 51KB (minified + gzipped) and takes a while to
execute, so for production apps it's recommended to only include the modules
that your application actually uses. Dependencies are automatically resolved.
Simply pick one or more modules from the asset list below.

For example, if you only need the datepicker module, add this to your
application.js:

```javascript
//= require jquery-ui/widgets/datepicker
```

In your application.css, require the corresponding CSS module (notice
no `widgets/` subdirectory here):

```css
/*
 *= require jquery-ui/datepicker
 */
```

## JavaScript Assets

### UI Core

```javascript
//= require jquery-ui/core
//= require jquery-ui/widget
//= require jquery-ui/position
```

You usually do not need to require these directly, as they are pulled in by the
other JavaScript modules as needed.

### Interactions

```javascript
//= require jquery-ui/widgets/mouse
//= require jquery-ui/widgets/draggable
//= require jquery-ui/widgets/droppable
//= require jquery-ui/widgets/resizable
//= require jquery-ui/widgets/selectable
//= require jquery-ui/widgets/sortable
```

For all but `jquery-ui/mouse` and `jquery-ui/droppable`, remember to `require` their matching CSS
files in your application.css as well.

### Widgets

```javascript
//= require jquery-ui/widgets/accordion
//= require jquery-ui/widgets/autocomplete
//= require jquery-ui/widgets/button
//= require jquery-ui/widgets/datepicker
//= require jquery-ui/widgets/dialog
//= require jquery-ui/widgets/menu
//= require jquery-ui/widgets/progressbar
//= require jquery-ui/widgets/selectmenu
//= require jquery-ui/widgets/slider
//= require jquery-ui/widgets/spinner
//= require jquery-ui/widgets/tabs
//= require jquery-ui/widgets/tooltip
```

For all of these, remember to `require` their matching CSS files in your
application.css as well.

#### I18n

Datepicker has optional i18n modules for non-US locales, named
`jquery-ui/datepicker-xx[-YY]`
([list](https://github.com/joliss/jquery-ui-rails/tree/master/app/assets/javascripts)),
for example:

```javascript
//= require jquery-ui/widgets/datepicker
//= require jquery-ui/i18n/datepicker-pt-BR
```

Note that you still need to include the main datepicker module. It is not
required automatically [for performance
reasons](https://github.com/joliss/jquery-ui-rails/issues/9#issuecomment-6524987).

### Effects

```javascript
//= require jquery-ui/effect.all
```

OR

```javascript
//= require jquery-ui/effects/effect
//= require jquery-ui/effects/effect-blind
//= require jquery-ui/effects/effect-bounce
//= require jquery-ui/effects/effect-clip
//= require jquery-ui/effects/effect-drop
//= require jquery-ui/effects/effect-explode
//= require jquery-ui/effects/effect-fade
//= require jquery-ui/effects/effect-fold
//= require jquery-ui/effects/effect-highlight
//= require jquery-ui/effects/effect-puff
//= require jquery-ui/effects/effect-pulsate
//= require jquery-ui/effects/effect-scale
//= require jquery-ui/effects/effect-shake
//= require jquery-ui/effects/effect-size
//= require jquery-ui/effects/effect-slide
//= require jquery-ui/effects/effect-transfer
```

## Stylesheet Assets

### UI Core

```css
/*
 *= require jquery-ui/core
 *= require jquery-ui/theme
 */
```

You might want to require these if you do not use any of the following modules,
but still want jQuery UI's basic theming CSS. Otherwise they are automatically
pulled in as dependencies.

### Interactions

```css
/*
 *= require jquery-ui/widgets/draggable
 *= require jquery-ui/widgets/resizable
 *= require jquery-ui/widgets/selectable
 *= require jquery-ui/widgets/sortable
 */
```

### Widgets

```css
/*
 *= require jquery-ui/accordion
 *= require jquery-ui/autocomplete
 *= require jquery-ui/button
 *= require jquery-ui/datepicker
 *= require jquery-ui/dialog
 *= require jquery-ui/menu
 *= require jquery-ui/progressbar
 *= require jquery-ui/selectmenu
 *= require jquery-ui/slider
 *= require jquery-ui/spinner
 *= require jquery-ui/tabs
 *= require jquery-ui/tooltip
 */
```

## Contributing

### Bug Reports

For bugs in jQuery UI itself, head to the [jQuery UI Development
Center](http://jqueryui.com/development).

For bugs in this gem distribution, use the GitHub issue tracker.

### Setup

The `jquery-ui-rails` gem should work in Ruby 1.8.7 apps. To run the rake
tasks, you need Ruby 1.9 however.

```bash
git clone git://github.com/joliss/jquery-ui-rails.git
cd jquery-ui-rails
git submodule update --init
bundle install
bundle exec rake # rebuild assets
```

Most of the code lives in the `Rakefile`. Pull requests are more than welcome!

### Hacking jQuery UI

The jquery-ui-rails repository is
[contributor-friendly](http://www.solitr.com/blog/2012/04/contributor-friendly-gems/)
and has a git submodule containing the official [jquery-ui
repo](https://github.com/jquery/jquery-ui). This way it's easy to hack the
jQuery UI code:

```bash
cd jquery-ui
git checkout master  # or 1-8-stable
... hack-hack-hack ...
bundle exec rake  # rebuild assets based on your changes
```

Assuming your app's Gemfile points at your jquery-ui-rails checkout (`gem
'jquery-ui-rails', :path => '~/path/to/jquery-ui-rails'`), all you need to do
now is refresh your browser, and your changes to jQuery UI are live in your
Rails application.

You can send pull requests to the
[jquery-ui](https://github.com/jquery/jquery-ui) GitHub project straight out of
your submodule. See also their
[Getting Involved](http://wiki.jqueryui.com/w/page/35263114/Getting-Involved)
guide.

### Testing

As a smoke test, a `testapp` application is available in the repository, which
displays a check mark and a datepicker to make sure the assets load correctly:

```bash
cd testapp
bundle install
rails server
```

Now point your browser at [http://localhost:3000/](http://localhost:3000/).

### Releasing

Be sure that `VERSIONS.md`, `History.md` and `lib/jquery/ui/rails/version.rb`
are up-to-date. Then build and push like so:

```bash
rake build
gem push pkg/jquery-ui-rails-X.Y.Z.gem
git tag vX.Y.Z
git push --tags
```

## Limitations

*   Only the base theme (Smoothness) is included. Once it becomes possible to
    [generate all theme
    files](https://forum.jquery.com/topic/downloading-bundling-all-themes#14737000003080244)
    from the jQuery UI sources, we can package all the other themes in the
    [ThemeRoller](http://jqueryui.com/themeroller/) gallery.

    Perhaps we can also add helper tasks to help developers generate assets for
    their own custom themes or for third-party themes (like
    [Selene](http://gravityonmars.github.com/Selene/)).

    If you still want a different theme right now, you could probably download
    a custom theme and require the theme CSS *after* requiring any other jQuery
    UI CSS files you need, making sure to serve up the theme images correctly.
    (This is arguably cumbersome, not officially supported by this gem, and
    adds 1 KB overhead as both the base theme and the custom theme are served
    up.)
