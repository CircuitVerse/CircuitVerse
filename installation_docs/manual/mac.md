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

     Install Mise to simplify the setup process:
     curl -sSL https://mise.jdx.dev/install.sh | bash
     mise install

     Note: Mise will automatically install necessary dependencies and configure your environment. This eliminates the need to install individual dependencies like Redis, PostgreSQL, Node.js, etc., manually.

#### Mise-managed Dependencies

Mise automatically manages the following development tools based on the versions specified in `.tool-versions`:
- Ruby 
- node
- yarn
- ImageMagick
- CMAKE
- Redis
This will automatically handle the installation of PostgreSQL, Redis, Ruby, and any other required dependencies for your project.
To view currently managed tools and their versions:
```bash
mise ls

Additionally, Mise will take care of installing and configuring PostgreSQL, Redis, Ruby, and any other required dependencies for your project. 



#### Setup
> **Note**: PostgreSQL and Redis *must* be running. PostgreSQL must be configured with a default user


1. Configure your PostgreSQL database in `config/database.yml` (copy `config/database.example.yml` for the template): 
     * **(macOS/linux):** `cp config/database.example.yml config/database.yml`
     * **Note:** The Postgres credentials need to be updated to your currently running database
2. Run Mise to set up and test the application:
     mise setup
     mise test
3. Create database: `bundle exec rails db:create`
4. Run database migrations: `bundle exec rails db:migrate`
5. Seed the database with some data: `bundle exec rails db:seed`
6. Generate RSA keypairs
     ```bash
     openssl genrsa -out ./config/private.pem 2048
     openssl rsa -in ./config/private.pem -outform PEM -pubout -out ./config/public.pem
     ```
7. Run `bin/dev` to run application server, background job queue and asset compiler

Navigate to `localhost:3000` in your web browser to access the website.
