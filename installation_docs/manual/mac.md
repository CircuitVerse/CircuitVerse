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
- [Mise Setup Tool](https://mise.jdx.dev/) :  
     ```bash
     # Mise Setup Tool

     # Download and verify
     curl -O https://mise.run
     curl -O https://mise.run.sha256
     shasum -a 256 -c mise.run.sha256
     sh mise.run
      
     # Add to shell (choose based on your shell):
     
     # For bash:
     echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
     # For zsh:
     echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
     
     # Verify installation
     mise --version
     mise install
          ```
- **Below dependencies can be installed at one step**
     ```bash
     brew bundle
     ```
     - OpenSSL

#### Mise-managed Dependencies

Mise automatically manages the following development tools based on the versions specified in `.tool-versions`:
- Ruby
- Node.js
- Redis
- PostgreSQL
- ImageMagick
- CMake

To view currently managed tools and their versions:
```bash
mise ls
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
