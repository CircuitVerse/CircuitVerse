source 'https://rubygems.org'

gemspec path: '../'

gem 'activerecord', '~> 5.2.0'
gem 'railties', '~> 5.2.0'

# Database Configuration
group :development, :test do
  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter', '~> 51.1'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 51.1'
    gem 'kramdown'
  end

  platforms :ruby, :rbx do
    gem 'sqlite3'
    gem 'mysql2'
    gem 'pg'
    gem 'redcarpet'
  end

  platforms :rbx do
    gem 'rubysl', '~> 2.0'
    gem 'rubinius-developer_tools'
  end
end
