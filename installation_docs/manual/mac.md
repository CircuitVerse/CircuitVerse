## Installation on macOS

#### Cloning From GitHub
To clone the repository, either use the Git GUI if you have one installed or enter the following commands:
```sh
git clone https://github.com/CircuitVerse/CircuitVerse.git --recursive
cd CircuitVerse
```

**Note:** If you want to contribute, first fork the original repository and clone your **forked** repository into your local machine. If you don't do this, you will not be able to make commits or change any files.
```sh
git clone https://github.com/<username>/CircuitVerse.git --recursive
cd CircuitVerse
```

- Use `git submodule update --init` to get the contents of the submodule if you missed using the `--recursive` option while cloning the repository or if you have already done so.

#### Dependencies
> Installation guide link and commands has been added to each dependency. You can skip the installation of the dependency if it is already installed.
- [Git](https://git-scm.com/) - using a GUI such as [SourceTree](https://www.sourcetreeapp.com/) or [GitHub Desktop](https://desktop.github.com/) can help
     ```bash
     brew install git
     ```
- [RVM](https://rvm.io/rvm/install)
     ```bash
     brew install gnupg
     gpg --keyserver keys.openpgp.org --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
     \curl -sSL https://get.rvm.io | bash -s stable
     ```
- Ruby 3.2.1
     ```bash
     rvm install 3.2.1
     rvm use 3.2.1
     ```
- **Below dependencies can be installed at one step**
     ```bash
     brew bundle
     ```
     - [Redis 7.0 [atleast]](https://redis.io/docs/getting-started/installation/install-redis-on-linux/)
     - [ImageMagick](https://imagemagick.org/) - Image manipulation library
     - [Node.js 22.x](https://nodejs.org/it/download)
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
8. Generate RSA keypairs
     ```bash
     openssl genrsa -out ./config/private.pem 2048
     openssl rsa -in ./config/private.pem -outform PEM -pubout -out ./config/public.pem
     ```
9. Run `bin/dev` to run application server, background job queue and asset compiler

Navigate to `localhost:3000` in your web browser to access the website.
