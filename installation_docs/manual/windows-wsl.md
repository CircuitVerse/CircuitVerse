## Installation on Windows (WSL)

 #### Setting up WSL
   1. Install WSL (Windows Subsystem for Linux) if not already installed. Follow the [official guide](https://learn.microsoft.com/en-us/windows/wsl/install).
   - Install Ubuntu as the default distribution (you can choose another Linux distribution, but these instructions assume Ubuntu).
    2. Open a terminal and update your system:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
   3. Set up WSL2 as the default version:
   ```powershell
   wsl --set-default-version 2
   ```
---

#### Cloning From GitHub
To clone the repository, either use the Git GUI if you have one installed or enter the following commands:
```bash
git clone https://github.com/CircuitVerse/CircuitVerse.git --recursive
cd CircuitVerse
```

**Note:** If you want to contribute, first fork the original repository and clone your **forked** repository into your local machine. If you don't do this, you will not be able to make commits or change any files.
```bash
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
- Ruby 3.4.1
     ```bash
     rvm install 3.4.1
     rvm use 3.4.1
     ```

### systemd on WSL (required for Redis and PostgreSQL)

> **Note:** systemd is **not enabled by default** in WSL, even on Windows 11.
> Before using `systemctl` for services like Redis or PostgreSQL, ensure:
>
> - You are using **WSL Store version 0.67.6 or newer**
> - `/etc/wsl.conf` contains:
>   ```ini
>   [boot]
>   systemd=true
>   ```
> - WSL has been restarted using:
>   ```powershell
>   wsl --shutdown
>   ```

- [Redis 7.0 [at least]](https://redis.io/docs/getting-started/installation/install-redis-on-linux/)
> Refer to **systemd on WSL** above for instructions on enabling systemd.
```bash
# If systemd is enabled in WSL
sudo systemctl enable redis-server
sudo systemctl start redis-server

# If systemd is NOT enabled in WSL
redis-server --daemonize yes

# Verify Redis is running
redis-cli ping
# Expected output: PONG
```

- [ImageMagick](https://imagemagick.org/) - Image manipulation library
     ```bash
     sudo apt install imagemagick
     ```
- [Node.js 22.x](https://nodejs.org/en/download/)
     ```bash
      # Install Node.js 20.x using nvm (Node Version Manager)
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
      source ~/.bashrc
      nvm install 22
      nvm use 22
     ```
- [Yarn](https://yarnpkg.com/getting-started/install)
     ```bash
     curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/yarn-archive-keyring.gpg
     echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
     sudo apt update && sudo apt install -y yarn
     ```
     <!-- Fixed indentation for yarn installation command -->
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
# Add PostgreSQL repository
> Refer to **systemd on WSL** above for instructions on enabling systemd.
```bash
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/postgresql.asc
sudo apt update
sudo apt install postgresql-17 postgresql-contrib libpq-dev

# Once systemd is enabled, you can manage PostgreSQL using:
sudo systemctl start postgresql.service
sudo systemctl enable postgresql.service

# If systemd is NOT enabled (most WSL setups)
sudo service postgresql start

# Verify PostgreSQL is running
pg_isready
```
#### Setup
 > **Note**: PostgreSQL and Redis *must* be running. PostgreSQL must be configured with a default user

 To set up the PostgreSQL user:
  ```bash
 sudo -u postgres createuser -s $(whoami)
 # Replace 'your_secure_password' with a strong password
 sudo -u postgres psql -c "ALTER USER $(whoami) WITH PASSWORD 'your_secure_password';"
 # Make sure to update this password in your database.yml configuration
   ```
1. Install Ruby bundler : `gem install bundler`
2. Install Ruby dependencies: `bundle install`
3. Install Yarn dependencies: `yarn`
4. Configure your PostgreSQL database in `config/database.yml` (copy `config/database.example.yml` for the template): 
     * **(macOS/linux):** `cp config/database.example.yml config/database.yml`
     * **Note:** The Postgres credentials need to be updated to your currently running database

     Example database.yml configuration:
 ```yaml
 default: &default
   adapter: postgresql
   encoding: unicode
   pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
   username: <%= ENV['DATABASE_USERNAME'] %>
   password: <%= ENV['DATABASE_PASSWORD'] %>
 
 development:
   <<: *default
   database: circuitverse_development
 ```
 Create a `.env` file from the template:
 ```bash
 cp .env.example .env
 ```
 Update the database credentials in your `.env` file:
 ```
 DATABASE_USERNAME=your_username
 DATABASE_PASSWORD=your_secure_password
 ```
5. Create database: `bundle exec rails db:create`
6. Run database migrations: `bundle exec rails db:migrate`
7. Seed the database with some data: `bundle exec rails db:seed`
8. Generate RSA keypairs
     ```bash
     # Generate a stronger 4096-bit key
      openssl genrsa -out ./config/private.pem 4096
      # Restrict private key permissions
      chmod 600 ./config/private.pem
    openssl rsa -in ./config/private.pem -outform PEM -pubout -out ./config/public.pem
     ```
9. Run `bin/dev` to run application server, background job queue and asset compiler
Navigate to `localhost:3000` in your web browser to access the website.
   Additional Notes for WSL
- Install `libssl-dev` for OpenSSL development headers if missing:
   ```bash
   sudo apt install libssl-dev
   ```
- If you face issues with file permissions or file changes not reflecting, ensure you are using WSL2 and the project directory is located within the WSL filesystem (`/home`), not the Windows file system (`C:\`).
