## Installation on MacOS

#### Cloning From GitHub
To clone the repository, either use the Git GUI if you have one installed or enter the following commands:
```sh
git clone https://github.com/CircuitVerse/CircuitVerse.git
cd CircuitVerse
```

**Note:** If you want to contribute, first fork the original repository and clone your **forked** repository into your local machine. If you don't do this, you will not be able to make commits or change any files.
```sh
git clone https://github.com/<username>/CircuitVerse.git
cd CircuitVerse
```

#### Dependencies
> Installation guide link has been added to each dependency
- [Git](https://git-scm.com/) - using a GUI such as [SourceTree](https://www.sourcetreeapp.com/) or [GitHub Desktop](https://desktop.github.com/) can help
- [RVM](https://rvm.io/rvm/install) 
- Ruby 3.2.1
- [Redis 7.0 [atleast]](https://redis.io/docs/getting-started/installation/install-redis-on-linux/)
- [ImageMagick](https://imagemagick.org/) - Image manipulation library
- [Node.js 16.x](https://nodejs.org/it/download)
- [Yarn](https://yarnpkg.com/getting-started/install)
- [CMAKE](https://cmake.org/install/)
- OpenSSL
- [PostgreSQL](https://www.postgresql.org/download/macosx/) (`12`) - Database


#### Setup
> **Note**: PostgreSQL and Redis *must* be running. PostgreSQL must be configured with a default user

1. Install Ruby bundler : `gem install bundler`
2. Install Ruby dependencies: `bundle install`
3. Install Yarn dependencies: `yarn`
4. Configure your PostgreSQL database in `config/database.yml` (copy `config/database.example.yml` for the template): 
     * **(macOS/linux):** `cp config/database.example.yml config/database.yml`
     * **Note:** The Postgres credentials need to be updated to your currently running database
5. Create database: `bundle exec rails db:create`
6. Run database migrations: `bundle exec rails db:migrate`
7. Seed the database with some data: `bundle exec rails db:seed`
8. Run `bin/dev` to run application server, background job queue and asset compiler

Navigate to `localhost:3000` in your web browser to access the website.