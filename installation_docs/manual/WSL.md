# Installation on Windows using WSL

### Prerequisites
Ensure you have the following installed:
- **Windows Subsystem for Linux (WSL):** Follow the [official guide](https://learn.microsoft.com/en-us/windows/wsl/install) to install and configure WSL. To verify WSL installation, open Command Prompt or PowerShell and run `wsl --list --verbose`. Ensure that your desired distribution is installed and set as the default.
- **Ubuntu 20.04 or later**: Recommended WSL distribution.
- **Git:** Install it via your WSL terminal: `sudo apt install git`.

### Cloning From GitHub
To clone the repository, execute the following commands in your WSL terminal:
```bash
git clone -c core.symlinks=true https://github.com/CircuitVerse/CircuitVerse.git --recursive
cd CircuitVerse
```
Note: If you want to contribute, first fork the original repository and clone your forked repository:

```bash
git clone -c core.symlinks=true https://github.com/<username>/CircuitVerse.git --recursive
cd CircuitVerse
```
- Use git submodule update --init to initialize submodules if you missed the --recursive option during cloning.

## Dependencies
Install the following dependencies on WSL:

### 1. Ruby 3.2.1
```bash
sudo apt update && sudo apt install -y software-properties-common
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt update && sudo apt install -y ruby3.2 ruby3.2-dev
gem install bundler
```
### 2. Node.js 16.x and Yarn
```bash
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs
npm install --global yarn
```
### 3. PostgreSQL (12)
```bash
sudo apt install -y postgresql libpq-dev
sudo service postgresql start
```
Configure PostgreSQL with a default user (i.e., the user that will manage the database):
```bash
sudo -u postgres createuser --interactive
sudo -u postgres createdb circuitverse
```
For example, you can create a user named {myuser} when prompted during the createuser step.

### 4.Redis
```bash
sudo apt install -y redis
sudo service redis start
```

## Dependencies
> Install the following dependencies on WSL:

### 1. Ruby 3.2.1
```bash
sudo apt update && sudo apt install -y software-properties-common
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt update && sudo apt install -y ruby3.2 ruby3.2-dev
gem install bundler
```

### 2. Node.js 16.x and Yarn
```bash
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs
npm install --global yarn
```
### 3. PostgreSQL (12)
```bash
sudo apt install -y postgresql libpq-dev
sudo service postgresql start
```
Configure PostgreSQL with a default user (i.e., the user that will manage the database):
```bash
sudo -u postgres createuser --interactive
sudo -u postgres createdb circuitverse
```
For example, you can create a user named myuser when prompted during the createuser step.

### 4. Redis
```bash
sudo apt install -y redis
sudo service redis start
```
### 5. Other dependencies
```bash
sudo apt install -y imagemagick cmake openssl
```

## Setup
Follow these steps to set up CircuitVerse:

> 1. Install Ruby dependencies (libraries and gems required for the Rails framework and this project to function properly):
```bash
bundle install
```
> 2. Install Yarn dependencies:
```bash
yarn
```
> 3. cConfigure your PostgreSQL database:

```bash
cp config/database.example.yml config/database.yml
```
Update config/database.yml with your PostgreSQL credentials.

> 4. Create and seed the database:
```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```
> 5. Generate RSA keypairs:
```bash
openssl genrsa -out ./config/private.pem 2048
openssl rsa -in ./config/private.pem -outform PEM -pubout -out ./config/public.pem
```
> 6. Run the application server:
```bash
bin/dev
```

### Access the Application
Open your web browser and navigate to http://localhost:3000 to access CircuitVerse. If the server does not start or the page does not load, ensure that PostgreSQL and Redis services are running, and check the server logs for errors using bin/dev or rails server commands. Additionally, verify that all dependencies are correctly installed.

