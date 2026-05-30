## Installation on Linux

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
     sudo apt install git
     ```
- [RVM](https://rvm.io/rvm/install) 
     ```bash
     sudo apt install curl gnupg
     gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
     curl -sSL https://get.rvm.io | bash -s stable
     ```
- Ruby 3.2.1
     ```bash
     rvm install 3.2.1
     rvm use 3.2.1
     ```
- [Redis 7.0 [atleast]](https://redis.io/docs/getting-started/installation/install-redis-on-linux/)
     ```bash
     sudo apt install lsb-release curl gpg
     curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
     echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
     sudo apt-get update
     sudo apt-get install redis
     ```
- [ImageMagick](https://imagemagick.org/) - Image manipulation library
     ```bash
     sudo apt install imagemagick
     ```
- [Node.js 22.x](https://nodejs.org/it/download)
     ```bash
     curl -sL https://deb.nodesource.com/setup_22.x | sudo bash
     sudo apt-get update && sudo apt-get install -y nodejs
     ```
- [Yarn](https://yarnpkg.com/getting-started/install)
     ```bash
     curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
     echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
     sudo apt update && sudo apt install -y yarn
     ```
- [CMAKE](https://cmake.org/install/)
     ```bash
     sudo apt install cmake
     ```
- OpenSSL
     ```bash
     sudo apt install openssl
     ```
- libpq-dev
     ```bash
     sudo apt-get install libpq-dev
     ```
- [PostgreSQL](https://www.postgresql.org/) (`12`) - Database
     ```bash
     sudo apt install postgresql postgresql-contrib
     sudo systemctl start postgresql.service
     sudo systemctl enable postgresql.service
     ```


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

#### Additional instructions for Ubuntu
Additional instructions can be found [here](https://www.howtoforge.com/tutorial/ubuntu-ruby-on-rails/) and there are some extra notes for single user installations:
- If you are facing difficulties installing RVM, most probably it is because of an older version of rvm shipped with Ubuntu's desktop edition and updating the same resolves the problem.
- [Run Terminal as a login shell](https://rvm.io/integration/gnome-terminal/) so ruby and rails will be available.
