# Setting up CircuitVerse
[Back to `README.md`](README.md)

## Setting up on cloud with Gitpod
[Gitpod](https://www.gitpod.io/) can be used to develop CircuitVerse in the cloud. Instructions are available in our [wiki](https://github.com/CircuitVerse/CircuitVerse/wiki/Development-on-Gitpod). Pull requests can be created in Gitpod by following these [steps](https://github.com/CircuitVerse/CircuitVerse/wiki/Pull-Requests-using-Gitpod).

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/CircuitVerse/CircuitVerse)

## Setting up development environment on local machine

## Required Software
- [Git](https://git-scm.com/) - using a GUI such as [SourceTree](https://www.sourcetreeapp.com/) or [GitHub Desktop](https://desktop.github.com/) can help.
- [Ruby on Rails](https://rubyonrails.org/)
- [PostgreSQL](https://www.postgresql.org/)
- [Yarn](https://yarnpkg.com/)
- [Redis](https://redis.io/)
- [ImageMagick](https://imagemagick.org/)

# Versions
- Ruby Version: ruby-2.6.5
- Rails Version: Rails 6.0.1
- PostgreSQL Version: 9.5

## Cloning From GitHub
To clone the repository, either use the Git GUI if you have one installed or enter the following commands:
```sh
git clone https://github.com/CircuitVerse/CircuitVerse.git
cd CircuitVerse
```
**Note:** If you want to contribute, first fork the original repository and clone the **forked** repository into your local machine. If you don't do this, you will not be able to make commits or change any files.
```sh
git clone https://github.com/<username>/CircuitVerse.git
cd CircuitVerse
```

## Setup Instructions
Please go through the [Contribution Guidelines](CONTRIBUTING.md) before going forward with any development. This helps us keep the process streamlined and results in better PRs.
You will also need the required software, detailed above. `Redis` and `PostgreSQL` should be running.

**Note:** You might want to use the docker instructions if you do not want to setup your own environment.

1. Install ruby using RVM, use ruby-2.6.5
1. Install bundler : `gem install bundler`
1. Install dependencies: `bundle install`
1. Install Yarn dependencies: `yarn`
1. Configure your PostgreSQL database in `config/database.yml` (copy `config/database.example.yml` for the template)
     * **Note:** The Postgres credentials need to be updated to your currently running database
1. Create database: `rails db:create`
1. Run migrations: `rails db:migrate`
1. Start Sidekiq: `bundle exec sidekiq -e development -q default -q mailers -d -L tmp/sidekiq.log` (currently in development)

Then, local development can be started with `rails s -b 127.0.0.1 -p 8080`. Navigate to `127.0.0.1:8080` in your web browser to access the website.

### CircuitVerse API setup instructions
CircuitVerse API uses `RSASSA` cryptographic signing that requires `private` and associated `public` key. To generate the keys RUN the following commands in `CircuitVerse/`
```
openssl genrsa -out config/private.pem 2048
openssl rsa -in config/private.pem -outform PEM -pubout -out config/public.pem
```

### Additional setup instructions
[Yarn](https://yarnpkg.com/lang/en/) is a package manager for the JavaScript ecosystem.
CircuitVerse uses Yarn for frontend package and asset management.

If you encounter the following error,
```
Error: File to import not found or unreadable: bootstrap/scss/bootstrap.scss
```
run `yarn` to install frontend dependencies

Additional software:
* Install imagemagick
* Start Redis server process.
* To start sidekiq: `bundle exec sidekiq -e development -q default -q mailers -d -L tmp/sidekiq.log` (In development)

### Development
Developers can quickly get started by setting up the dev environment using the instructions above. To seed the database with some sample data, run `bundle exec rake db:seed`. The admin credentials after seeding will be:
```
User: Admin
Email: admin@circuitverse.org
Password: password
```

For debugging include `binding.pry` anywhere inside the code to open the `pry` console.


### Production
The following commands should be run for production:
```
bundle install --with pg --without development test
RAILS_ENV=production bundle exec rake assets:precompile
bundle exec sidekiq -e production -q default -q mailers -d -L tmp/sidekiq.log
```

### Deploy to Heroku
You will be redirected to the Heroku page for deployment on clicking the below button.
Make sure that you fill in the `Config Vars` section before deploying it.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CircuitVerse/CircuitVerse)


### Additional instructions for Ubuntu
Additional instructions can be found [here](https://www.howtoforge.com/tutorial/ubuntu-ruby-on-rails/) and there are some extra notes for single user installations:
- If you are facing difficulties installing RVM, most probably it is because of an older version of rvm shipped with Ubuntu's desktop edition and updating the same resolves the problem.
- [Run Terminal as a login shell](https://rvm.io/integration/gnome-terminal/) so ruby and rails will be available.

  - Removing RVM
    ```
    sudo apt-get --purge remove ruby-rvm
    sudo rm -rf /usr/share/ruby-rvm /etc/rvmrc /etc/profile.d/rvm.sh
    ```
  - Installing new version of RVM
    ```
    curl -L https://get.rvm.io |
    bash -s stable --ruby --autolibs=enable --auto-dotfiles
    ```
- If you are facing errors running the `rails db:create` ensure that the socket file(i.e `mysql.sock`) is present in that location. Some possible locations where it might be present is `/run/mysqld/mysqld.sock` or `/var/lib/mysql/mysql.sock`.

## Running Tests
Before making a pull request, it is a good idea to check that all tests are passing locally. To run the system tests, run `bundle exec rspec` or `bin/rake spec:all`

**Note:** To pass the system tests, you need the [Chrome Browser](https://www.google.com/chrome/) installed.

## Docker Instructions
[Docker](https://www.docker.com/) creates a virtual machine on your PC, which negates the need to install other software or issue the setup instructions manually. This is optional.

**Note:** Docker will not run on Windows 10 Home Edition.

### Usage
* Run `docker-compose up` to run the instance
* Run `docker-compose down` to stop the instance
* Run `docker-compose build --no-cache` to rebuild the instance (make sure the instance is not running first)


## Configuring Third Party Services
Follow these instructions if you would like to link `Google`, `Facebook` or `GitHub` to your CircuitVerse instance:
1. First create a Google, Facebook or Github app by following this [wiki](https://github.com/CircuitVerse/CircuitVerse/wiki/Create-Apps).
2. Make the following changes in your Google, Facebook or Github app:
   1.  Update the `site url` field with the URL of your instance, and update the `callback url` field with `<url>/users/auth/google`, `<url>/users/auth/facebook` or `<url>/users/auth/github` respectively.
3. Configure your `id` and `secret` environment variables in `.env`. If `.env` does not exist, copy the template from `.env.example`.
4. After adding the environment variables, run `dotenv rails server` to start the application.
