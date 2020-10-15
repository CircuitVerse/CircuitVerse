Contributing author: @fpintos

# Running the application

- **Docker**: I've tried and manage to run the project in Docker for Windows without much trouble (on Windows 10). I did however had to create a local account in my machine (since I usually log-in with an AzureAD account) and then I had to share the drive where I had the code with Docker (in Docker->Settings->Shared Drives). Then I ran docker-compose and docker up and things worked as expected.

- **Bash-on-Windows**: I'm able to run the project in a Windows machine running the project in an Ubuntu-on-Windows bash shell; these instructions were helpful:
  https://gorails.com/setup/windows/10
  https://medium.com/koaandco/rails-5-postgresql-on-wsl-9b1315ac0679

- **Ubuntu on Hyper-V**: I've tried, it worked, but it ended up being too slow for my taste (on a Surface Book) so I gave up on it. Other machines might have better luck.

- **CodeBase**:
  - The ruby code-base contains the server-side code; this includes user, groups and project management.
  - The javascript code (under public/js) contains the client UI and the simulator code.

You can work in the simulator without touching the ruby code, but you will need to setting up your database config file, so the ruby server can run and serve the simulator pages.rite its contents to the browser's console; this is meant as a debugging facility.
