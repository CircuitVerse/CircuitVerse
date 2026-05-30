## Installation on Windows

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
- [Node.js 22.x](https://nodejs.org/it/download)
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