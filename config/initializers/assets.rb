# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "3.0"

Rails.application.config.assets.quite = false

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
 Rails.application.config.assets.paths << Rails.root.join('node_modules')
 Rails.application.config.assets.precompile += %w[simulator.css simulator.js application_sprockets.js application.js testbench.js testbench.css mailer.css]
 Rails.application.config.assets.precompile += ["*.svg", "*.eot", "*.woff", "*.woff2", "*.ttf", "*.otf", "*.png"]

Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'images')

Rails.application.config.assets.precompile += %w( svgs/*.svg )

