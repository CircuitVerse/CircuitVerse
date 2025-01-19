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
To clone the repository, enter the following commands:
```bash
git clone https://github.com/CircuitVerse/CircuitVerse.git --recursive
cd CircuitVerse
```
**Note:** If you plan to contribute, fork the repository and clone your **forked** repository:
```bash
git clone https://github.com/<username>/CircuitVerse.git --recursive
cd CircuitVerse
```
If you missed the `--recursive` option, run:
```bash
git submodule update --init
```
---
#### Dependencies
> Install the following dependencies. If they are already installed, you can skip the relevant steps.
- **Git**
   ```bash
   sudo apt install git
   ```
- **RVM**
   ```bash
   sudo apt install curl gnupg
   gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
   curl -sSL https://get.rvm.io | bash -s stable
   ```
- **Ruby 3.2.1**
   ```bash
   rvm install 3.2.1
   rvm use 3.2.1
   ```
- **Redis 7.0 [at least]**
   ```bash
   sudo apt install lsb-release curl gpg
   curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
   sudo apt-get update
   sudo apt-get install redis
   ```
- **ImageMagick**
   ```bash
   sudo apt install imagemagick
   ```
- **Node.js 16.x**
   ```bash
   curl -sL https://deb.nodesource.com/setup_16.x | sudo bash
   sudo apt-get update && sudo apt-get install -y nodejs
   ```
- **Yarn**
   ```bash
   curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
   echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
   sudo apt update && sudo apt install -y yarn
   ```
- **CMAKE**
   ```bash
   sudo apt install cmake
   ```
- **OpenSSL**
   ```bash
   sudo apt install openssl
   ```
- **libpq-dev**
   ```bash
   sudo apt-get install libpq-dev
   ```
- **PostgreSQL 12**
   ```bash
   sudo apt install postgresql postgresql-contrib
   sudo systemctl start postgresql.service
   sudo systemctl enable postgresql.service
   ```
---
#### Setup
> **Note:** PostgreSQL and Redis *must* be running. PostgreSQL must be configured with a default user.
1. Install Ruby bundler:
   ```bash
   gem install bundler
   ```
2. Install Ruby dependencies:
   ```bash
   bundle install
   ```
3. Install Yarn dependencies:
   ```bash
   yarn
   ```
4. Configure your PostgreSQL database in `config/database.yml` (copy `config/database.example.yml` for the template):
   ```bash
   cp config/database.example.yml config/database.yml
   ```
   - **Note:** Update the Postgres credentials to match your running database.
5. Create database:
   ```bash
   bundle exec rails db:create
   ```
6. Run database migrations:
   ```bash
   bundle exec rails db:migrate
   ```
7. Seed the database with some data:
   ```bash
   bundle exec rails db:seed
   ```
8. Generate RSA keypairs:
   ```bash
   openssl genrsa -out ./config/private.pem 2048
   openssl rsa -in ./config/private.pem -outform PEM -pubout -out ./config/public.pem
   ```
9. Run the application server, background job queue, and asset compiler:
   ```bash
   bin/dev
   ```
Navigate to `localhost:3000` in your web browser to access the website.
---
#### Additional Notes for WSL
- Install `libssl-dev` for OpenSSL development headers if missing:
   ```bash
   sudo apt install libssl-dev
   ```
- If you face issues with file permissions or file changes not reflecting, ensure you are using WSL2 and the project directory is located within the WSL filesystem (`/home`), not the Windows file system (`C:\`).