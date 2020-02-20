# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://circuitverse.org"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #

  User.find_each do |user|
    add user_projects_path(user), lastmod: user.current_sign_in_at
  end

  Project.find_each do |project|
    add user_project_path(project.author, project), lastmod: project.updated_at
  end

  add about_index_path
  add featured_circuits_path
  add simulator_new_path
  add examples_path
  add gettingStarted_path
  add privacy_index_path
  add contribute_path
  add teachers_path
end
