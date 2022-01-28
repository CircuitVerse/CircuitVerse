# Setting up CircuitVerse
[Back to `README.md`](README.md)

Please go through the [Contribution Guidelines](CONTRIBUTING.md) before going forward with any development. This helps us keep the process streamlined and results in better PRs.

If you have any setup problems, please ensure you have read through all the instructions have all the required software installed before creating an issue.

## Installation
There are several ways to run your own instance of CircuitVerse:

### Gitpod Cloud Environment
[Gitpod](https://www.gitpod.io/) is a free platform that allows you to develop CircuitVerse in a cloud VS Code environment. 

Instructions are available in our [wiki](https://github.com/CircuitVerse/CircuitVerse/wiki/Development-on-Gitpod) and pull requests can be created following these [steps](https://github.com/CircuitVerse/CircuitVerse/wiki/Pull-Requests-using-Gitpod).

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/CircuitVerse/CircuitVerse)

### Docker Local Environment
[Docker](https://www.docker.com/) can be used to create virtual machines on your PC so you don't have to setup dependencies (e.g. PostgreSQL and Redis) manually.

**Note**: Please follow [these](https://docs.docker.com/docker-for-windows/install-windows-home/) instructions for installing Docker on Windows 10 Home

#### Usage
* Run `docker-compose up` to run the instance
* Run `docker-compose down` to stop the instance
* Run `docker-compose build --no-cache` to rebuild the instance (make sure the instance is not running first)

### Manual Setup (Local Environment)
#### Dependencies
**Note**: PostgreSQL and Redis *must* be running. PostgreSQL must be configured with a default user
- [Git](https://git-scm.com/) - using a GUI such as [SourceTree](https://www.sourcetreeapp.com/) or [GitHub Desktop](https://desktop.github.com/) can help.
- [Ruby](https://www.ruby-lang.org/en/) (`ruby-3.0.3`)
- [PostgreSQL](https://www.postgresql.org/) (`12`) - Database
- [Yarn](https://yarnpkg.com/) - JavaScript package manager
- [Redis](https://redis.io/) - Data structure store
- [ImageMagick](https://imagemagick.org/) - Image manipulation library

##### Redis on Windows
Redis can be installed from the [MicrosoftArchive Redis repository](https://github.com/MicrosoftArchive/redis/releases).

It can also be run natively or through [Docker Desktop](https://hub.docker.com/_/redis) if you have the [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/about) enabled.

#### Cloning From GitHub
To clone the repository, either use the Git GUI if you have one installed or enter the following commands:
```sh
git clone https://github.com/CircuitVerse/CircuitVerse.git
cd CircuitVerse
```
If you are cloning on Windows machine, use following command with an **administrative shell** to clone the repo.

```sh
git clone -c core.symlinks=true https://github.com/CircuitVerse/CircuitVerse.git
cd CircuitVerse
```

**Note:** If you want to contribute, first fork the original repository and clone your **forked** repository into your local machine. If you don't do this, you will not be able to make commits or change any files.
```sh
git clone https://github.com/<username>/CircuitVerse.git
cd CircuitVerse
```

#### Setup
1. Install Ruby bundler : `gem install bundler`
2. Install Ruby dependencies: `bundle install`
3. Install Yarn dependencies: `yarn`
4. Configure your PostgreSQL database in `config/database.yml` (copy `config/database.example.yml` for the template)
     * **Note:** The Postgres credentials need to be updated to your currently running database
5. Create database: `rails db:create`
6. Run database migrations: `rails db:migrate`
7. Run bin/dev to run application server, background job queue and asset compiler

Navigate to `localhost:3000` in your web browser to access the website.

#### Additional instructions for Ubuntu
Additional instructions can be found [here](https://www.howtoforge.com/tutorial/ubuntu-ruby-on-rails/) and there are some extra notes for single user installations:
- If you are facing difficulties installing RVM, most probably it is because of an older version of rvm shipped with Ubuntu's desktop edition and updating the same resolves the problem.
- [Run Terminal as a login shell](https://rvm.io/integration/gnome-terminal/) so ruby and rails will be available.

### CircuitVerse API documentation setup instructions
To setup CircuitVerse API documentation, refer [docs/README.md](docs/README.md)

### Additional setup instructions
[Yarn](https://yarnpkg.com/lang/en/) is a package manager for the JavaScript ecosystem.
CircuitVerse uses Yarn for frontend package and asset management.
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
### Heroku Deployment
[Heroku](https://www.heroku.com) is a free cloud platform that can be used for deployment of CircuitVerse

You will be redirected to the Heroku page for deployment on clicking the below button. Make sure that you fill in the `Config Vars` section before deploying it.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CircuitVerse/CircuitVerse)


## Development
To seed the database with some sample data, run `bundle exec rake db:seed`. This will add the following admin credentials:
```
User: Admin
Email: admin@circuitverse.org
Password: password
```

You can include `binding.pry` anywhere inside the code to open the `pry` console.

<!-- CircuitVerse uses webpack to bundle the javascript module and assets. To see any changes made to the simulator code without refreshing (hot reload), start `bin/webpack-dev-server` -->


## Production
The following commands should be run for production:
```
bundle install --with pg --without development test
RAILS_ENV=production bundle exec rake assets:precompile
bundle exec sidekiq -e production -q default -q mailers -d -L tmp/sidekiq.log
```


## Tests
Before making a pull request, it is a good idea to check that all tests are passing locally. To run the system tests, run `bundle exec rspec`

**Note:** To pass the system tests, you need the [Chrome Browser](https://www.google.com/chrome/) installed.


## API Setup
CircuitVerse API uses `RSASSA` cryptographic signing that requires `private` and associated `public` key. To generate the keys RUN the following commands in `CircuitVerse/`
```
openssl genrsa -out config/private.pem 2048
openssl rsa -in config/private.pem -outform PEM -pubout -out config/public.pem
```

## Third Party Services
The `.env` file only needs to be used if you would like to link to third party services (Facebook, Google, GitHub, Slack, Bugsnap and Recaptcha)

1. Create an app on the third party service [(instructions)](https://github.com/CircuitVerse/CircuitVerse/wiki/Create-Apps)
2. Make the following changes in your Google, Facebook or Github app:
   1.  Update the `site url` field with the URL of your instance, and update the `callback url` field with `<url>/users/auth/google`, `<url>/users/auth/facebook` or `<url>/users/auth/github` respectively.
3. Configure your `id` and `secret` environment variables in `.env`. If `.env` does not exist, copy the template from `.env.example`.
4. After adding the environment variables, run `dotenv rails server` to start the application.
