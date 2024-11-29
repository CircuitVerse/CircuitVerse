## Installation on Windows (Native)

#### Cloning From GitHub
To clone the repository, use following command with an **administrative shell**

```sh
git clone -c core.symlinks=true https://github.com/CircuitVerse/CircuitVerse.git --recursive
cd CircuitVerse
```

**Note:** If you want to contribute, first fork the original repository and clone your **forked** repository into your local machine. If you don't do this, you will not be able to make commits or change any files.
```sh
git clone -c core.symlinks=true https://github.com/<username>/CircuitVerse.git --recursive
cd CircuitVerse
```

- Use `git submodule update --init` to get the contents of the submodule if you missed using the `--recursive` option while cloning the repository or if you have already done so.

#### Dependencies
> Installation guide link has been added to each dependency
- [Git](https://git-scm.com/download/win) - using a GUI such as [SourceTree](https://www.sourcetreeapp.com/) or [GitHub Desktop](https://desktop.github.com/) can help
- [Ruby 3.2.1](https://www.ruby-lang.org/en/) (Install from this [link](https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.2.1-1/rubyinstaller-devkit-3.2.1-1-x64.exe))
    > During installation, you will be prompted to install MSYS2 & MINGW. Make sure to install those 
- Redis 7.0 [atleast]
    > Note : Redis 7.0 is not officially supported on Windows. Please note that any suggestions for unofficial software are provided solely for informational purposes, and their use is at your own risk.
    - Unofficial Windows port of Redis 7.0 
        - Clone the repository 
            ```bash
            git clone https://github.com/zkteco-home/redis-windows
            ```
        - `cd redis-windows`
        - Open powershell & Run `install_redis.cmd`
    - Memurai (Redis for Windows alternative)
        - Download the installer from [here](https://www.memurai.com/get-memurai)
        - Run the installer
- [ImageMagick](https://imagemagick.org/) - Image manipulation library
- [Node.js 16.x](https://nodejs.org/it/download)
- [Yarn](https://yarnpkg.com/getting-started/install)
- [CMAKE](https://cmake.org/install/)
- OpenSSL
- libpq-dev
- [PostgreSQL](https://www.postgresql.org/) (`12`) - Database


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
8. Open GIT bash in current folder
9. Generate RSA keypairs
     ```bash
     openssl genrsa -out ./config/private.pem 2048
     openssl rsa -in ./config/private.pem -outform PEM -pubout -out ./config/public.pem
     ```
10. Run `bin/dev` to run application server, background job queue and asset compiler

Navigate to `localhost:3000` in your web browser to access the website.

## Installation on Windows (WSL)

### Set up WSL

To set up wsl on your windows native, run the following command with an **administrative shell**

```sh
wsl --install
wsl --list --verbose
```
This shows the installed distributions and the WSL version in use. By default, it should say "Ubuntu" and "WSL 2".

>**Note:** We recommend using WSL 2 so if the previous output shows 1 then duly update/switch to WSL 2 with this command.
```sh
wsl --set-version <distribution-name> 2
```
### Install Dependencies
- Update and Install basic tools

    ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y build-essential git curl libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev
    ```
- [Git](https://git-scm.com/) - using a GUI such as [SourceTree](https://www.sourcetreeapp.com/) or [GitHub Desktop](https://desktop.github.com/) can help
     ```bash
     sudo apt install git
     ```
- [RVM](https://rvm.io/rvm/install) 
     ```bash
     sudo apt update
     sudo apt install -y curl gnupg2 build-essential
     gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
     ```
     >**Note** If the above command fails, manually import the keys using -
     ```bash
     curl -sSL https://rvm.io/mpapis.asc | gpg --import -
     curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
     ```
     Moving forward, install RVM
     ```bash 
     curl -sSL https://get.rvm.io | bash -s stable
     source ~/.rvm/scripts/rvm
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
- [Node.js 18.x](https://nodejs.org/it/download) and [Yarn](https://yarnpkg.com/getting-started/install)
     ```bash
     curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
     sudo apt install -y nodejs
     npm install --global yarn

     ```
- [CMAKE](https://cmake.org/install/)
     ```bash
     sudo apt install cmake
     ```
- OpenSSL **error**
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
> **Note**: PostgreSQL and Redis *must* be running. PostgreSQL must be configured with a default user.

1. Install Ruby bundler : `gem install bundler`
2. Install Ruby dependencies: `bundle install`
3. Install Yarn dependencies: `yarn`
4. Configure your PostgreSQL database in `config/database.yml` (copy `config/database.example.yml` for the template): 
     * `cp config/database.example.yml config/database.yml`
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

