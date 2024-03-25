# app/helpers/vite_helper.rb

module ViteHelper
  def vite_javascript_tag(*_names,
                          type: "module",                         
                          skip_preload_tags: false,
                          skip_style_tags: false,
                          crossorigin: "anonymous",
                          media: "screen",
                          **options)
    # Determine the version from the query parameter
    version = params[:simv] || "v2" # Default to v1 if version query parameter is not provided

    # Construct the path based on the simv
    path = "/#{version}/vite/entrypoints/simulator.js"

    # Generate the JavaScript tag
    tag = javascript_include_tag(path, crossorigin: crossorigin, type: type, extname: false, **options)

    # Generate preload tag if necessary
    tag << vite_preload_tag(path, crossorigin: crossorigin, **options) unless skip_preload_tags

    # Set extname option to false for Rails version >= 7
    options[:extname] = false if Rails::VERSION::MAJOR >= 7

    # Generate stylesheet link tag if necessary
    tag << stylesheet_link_tag(*entries.fetch(:stylesheets), media: media, **options) unless skip_style_tags

    tag  # Return the generated tag
  end
end
