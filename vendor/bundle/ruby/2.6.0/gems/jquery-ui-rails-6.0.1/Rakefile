Encoding.default_external = "UTF-8" if defined?(Encoding)
require 'json'
require 'bundler/gem_tasks'

# returns the source filename for a named file in the 'dependencies'
# array of a JSON build file
# (e.g., if the JSON build file contains
#
#    "dependencies": {
#      "jquery": ">=1.6",
#      "ui.core": "1.9.2",
#      "ui.widget": "1.9.2"
#    },
#
# then "ui.widget" returns "widget.js")
#
# The only exception is "jquery", which doesn't follow the
# same naming conventions so it's a special case.
def source_file_for_dependency_entry(caller, dep_entry)
  p = Pathname.new caller
  parent_path = p.parent
  parent_path.join(dep_entry + '.js').to_s
end

# return a Hash of dependency info, whose keys are jquery-ui
# source files and values are Arrays containing the source files
# they depend on
def map_dependencies
  dependencies = {}
  Dir.glob("jquery-ui/ui/**/*.js").each do |path|
    basename = File.basename path
    file = File.read path

    matchdata = file.match(/define\(\s*\[\s*([\"\.\/\,\w\s-\:]+)\]/m)

    next if matchdata.nil?

    deps = matchdata[1]

    # remove lines with comments
    deps = deps.gsub(/\/\/.+\s/, "")

    # remove all non-path symbols
    deps = deps.gsub(/[\r\n\t\"\[\]\s]/, "")

    deps_paths = deps.split(',')

    deps_paths.map!(&method(:remove_js_extension))

    # None of jquery.ui files should depend on jquery.js,
    # so we remove 'jquery' from the list of dependencies for all files
    deps_paths.reject! {|d| d == "jquery" }

    deps_paths.map! {|d| source_file_for_dependency_entry path, d }

    dependencies[basename] = deps_paths
  end
  dependencies
end

def dependency_hash
  @dependency_hash ||= map_dependencies
end

def version
  JSON.load(File.read('jquery-ui/package.json'))['version']
end

task :submodule do
  sh 'git submodule update --init' unless File.exist?('jquery-ui/README.md')
end

def get_js_dependencies(basename)
  dependencies = dependency_hash[basename]
  if dependencies.nil?
    puts "Warning: No dependencies found for #{basename}"
    dependencies = []
  end
  # Make sure we do not package assets with broken dependencies
  dependencies.each do |dep|
    unless File.exist?("#{dep}")
      fail "#{basename}: missing #{dep}"
    end
  end
  dependencies
end

def remove_js_extension(path)
  path.chomp(".js")
end

def protect_copyright_notice(source_code)
  # YUI does not minify comments starting with "/*!"
  # The i18n files start with non-copyright comments, so we require a newline
  # to avoid protecting those
  source_code.gsub!(/\A\s*\/\*\r?\n/, "/*!\n")
end

def build_image_dependencies(source_code)
  image_dependencies = Set.new source_code.scan(/url\("?images\/([-_.a-zA-Z0-9]+)"?\)/).map(&:first)
  code = image_dependencies.inject("") do |acc, img|
    acc += " *= depend_on_asset \"jquery-ui/#{img}\"\n"
  end
end

desc "Remove the app directory"
task :clean do
  rm_rf 'app'
end

desc "Generate the JavaScript assets"
task :javascripts => :submodule do
  Rake.rake_output_message 'Generating javascripts'

  target_dir = "app/assets/javascripts"
  target_ui_dir = "#{target_dir}/jquery-ui"
  mkdir_p target_ui_dir
  mkdir_p target_ui_dir + '/effects'
  mkdir_p target_ui_dir + '/widgets'
  mkdir_p target_ui_dir + '/i18n'

  Dir.glob("jquery-ui/ui/**/*.js").each do |path|
    basename = File.basename(path)
    clean_path = path.gsub('/ui', '')
    dep_modules = get_js_dependencies(basename).map(&method(:remove_js_extension))
    File.open("#{target_dir}/#{clean_path}", "w") do |out|
      dep_modules.each do |mod|
        mod.gsub!('/ui', '')
        out.write("//= require #{mod}\n")
      end
      # core.js is deprecated and uses define function which is usually unavailable
      # so we need only dependency loading there with no file contents
      next if clean_path == 'jquery-ui/core.js'
      out.write("\n") unless dep_modules.empty?
      source_code = File.read(path)
      source_code.gsub!('@VERSION', version)
      protect_copyright_notice(source_code)
      out.write(source_code)
    end
  end

  # process the i18n files separately for performance, since they will not have dependencies
  # https://github.com/joliss/jquery-ui-rails/issues/9
  Dir.glob("jquery-ui/ui/i18n/*.js").each do |path|
    basename = File.basename(path)
    File.open("#{target_ui_dir}/i18n/#{basename}", "w") do |out|
      source_code = File.read(path)
      source_code.gsub!('@VERSION', version)
      protect_copyright_notice(source_code)
      out.write(source_code)
    end
  end

  File.open("#{target_ui_dir}/effect.all.js", "w") do |out|
    Dir.glob("jquery-ui/ui/effects/*.js").sort.each do |path|
      clean_path = remove_js_extension(path).gsub('/ui', '')
      out.write("//= require #{clean_path}\n")
    end
  end
  File.open("#{target_dir}/jquery-ui.js", "w") do |out|
    Dir.glob("jquery-ui/ui/*.js").sort.each do |path|
      clean_path = remove_js_extension(path).gsub('/ui', '')
      out.write("//= require #{clean_path}\n")
    end
    Dir.glob("jquery-ui/ui/effects/*.js").sort.each do |path|
      clean_path = remove_js_extension(path).gsub('/ui', '')
      out.write("//= require #{clean_path}\n")
    end
    Dir.glob("jquery-ui/ui/widgets/*.js").sort.each do |path|
      clean_path = remove_js_extension(path).gsub('/ui', '')
      out.write("//= require #{clean_path}\n")
    end
  end
end

desc "Generate the CSS assets"
task :stylesheets => :submodule do
  Rake.rake_output_message 'Generating stylesheets'

  target_dir = "app/assets/stylesheets"
  target_ui_dir = "#{target_dir}/jquery-ui"
  mkdir_p target_ui_dir

  File.open("#{target_dir}/jquery-ui.css", "w") do |out|
    out.write("//= require jquery-ui/all\n")
  end

  css_dir = "jquery-ui/themes/base"
  Dir.glob("#{css_dir}/*.css").each do |path|
    basename = File.basename(path)
    source_code = File.read(path)
    source_code.gsub!('@VERSION', version)
    protect_copyright_notice(source_code)
    extra_dependencies = []
    # Is "theme" listed among the dependencies for the matching JS file?
    unless basename =~ /\.(all|base|core)\./
      if dependencies = dependency_hash[basename.sub(/\.css/, '.js')]
        dependencies.each do |dependency|
          dependency = dependency.sub(/\.js$/, '')
          dependent_stylesheet = "#{dependency}.css"
          extra_dependencies << dependency if File.exists?("#{css_dir}/#{dependent_stylesheet}")
        end
        extra_dependencies << 'theme'
      end
    end
    extra_dependencies.reverse.each do |dep|
      # Add after first comment block
      source_code = source_code.sub(/\A((.*?\*\/\n)?)/m, "\\1/*\n *= require jquery-ui/#{dep}\n */\n")
    end
    # Use "require" instead of @import
    source_code.gsub!(/^@import (.*)$/) { |s|
      m = s.match(/^@import (url\()?"(?<module>[-_.a-zA-Z]+)\.css"\)?;/) \
        or fail "Cannot parse import: #{s}"
      "/*\n *= require jquery-ui/#{m['module']}\n */"
    }
    # Be cute: collapse multiple require comment blocks into one
    source_code.gsub!(/^( \*= require .*)\n \*\/(\n+)\/\*\n(?= \*= require )/, '\1\2')
    source_code.gsub!(/\A(\/\*!.+?\*\/\s)/m, "\\1\n/*\n#{build_image_dependencies(source_code)} */\n\n") unless build_image_dependencies(source_code).empty?
    # Replace hard-coded image URLs with asset path helpers
    image_re = /url\("?images\/([-_.a-zA-Z0-9]+)"?\)/
    extname = source_code =~ image_re ? ".erb" : ""
    source_code.gsub!(image_re, 'url(<%= image_path("jquery-ui/\1") %>)')
    File.open("#{target_ui_dir}/#{basename}#{extname}", "w") do |out|
      out.write(source_code)
    end
  end
end

desc "Generate the image assets"
task :images => :submodule do
  Rake.rake_output_message 'Copying images'

  target_dir = "app/assets/images/jquery-ui"
  mkdir_p target_dir

  FileUtils.cp(Dir.glob("jquery-ui/themes/base/images/*"), target_dir)
end

desc "Update Jquery::Ui::Rails::JQUERY_UI_VERSION"
task :version => :submodule do
  Rake.rake_output_message "Setting Jquery::Ui::Rails::JQUERY_UI_VERSION = \"#{version}\""

  versionRb = 'lib/jquery/ui/rails/version.rb'
  versionRbSource = File.read(versionRb)
  versionDefinition = "JQUERY_UI_VERSION = \"#{version}\""
  versionRbSource.sub! /JQUERY_UI_VERSION = "[^"]*"/, versionDefinition \
    or fail "Could not find JQUERY_UI_VERSION in #{versionRb}"
  File.open(versionRb, 'w') do |out|
    out.write(versionRbSource)
  end
end

desc "Clean and then generate everything (default)"
task :assets => [:clean, :javascripts, :stylesheets, :images, :version]

task :build => :assets

task :default => :assets
