# README

[![Gitter](https://badges.gitter.im/CircuitVerse/community.svg)](https://gitter.im/CircuitVerse/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

## Versions
- Ruby Version: ruby-2.5.1
- Rails Version: Rails 5.1.6
- PostgreSQL Version: 9.5

## Setup Instructions

**Note:** You might want to use the docker instructions if you do not want to setup your own environment. 

* Install ruby using RVM, use ruby-2.5.1
* Install Dependencies: `bundle install --without production`
* Configure your DB in config/database.yml, copy config/database.yml.example
* Create database: `rails db:create`
* Run Migrations: `rails db:migrate`
* At this point, local development can be started with ```rails s -b 127.0.0.1 -p 8080```

Additional software:
* Install imagemagick
* Start Redis server process.
* To start sidekiq: `bundle exec sidekiq -e development -q default -q mailers -d -L tmp/sidekiq.log` (In development)

## Docker Instructions

* Install docker and docker-compose
* Run: `docker-compose up`

If you need to rebuild, run this before `docker-compose up`
```
docker-compose down 
docker-compose build --no-cache
```

## Developer Instructions
Developers can quickly get started by setting up the dev environment using the instructions above. The database is seeded with the following admin account. 
```
User: Admin
Email: admin@circuitverse.org
Password: password
```

For debugging include `binding.pry` anywhere inside the code to open the `pry` console.

## Additional setup instructions for Ubuntu
Additional instructions can be found [here](https://www.howtoforge.com/tutorial/ubuntu-ruby-on-rails/) and there are some extra notes for single user installations:
- If setting up Postgres with these instructions, use your user name instead of 'rails_dev'.
- [Run Terminal as a login shell](https://rvm.io/integration/gnome-terminal/) so ruby and rails will be available.
- You can remove `gem mysql2` from the gemfile (but don't check it in), move `gem pg` up and create the database.yml file with just Postgres. Example:
```
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <your user name>
  password: <postgres password>

development:
  <<: *default
  database: circuitverse_development

test:
  <<: *default
  database: circuitverse_test

production:
  <<: *default
  database: circuitverse_production
  username: circuitverse
  password: <%= ENV['circuitverse_DATABASE_PASSWORD'] %>
```

- If you are facing difficulties installing RVM, most probably it is because of an older version of rvm shipped with Ubuntu's desktop edition and updating the same resolves the problem.

  Removing RVM
  ```  
  sudo apt-get --purge remove ruby-rvm` <br /> 
  sudo rm -rf /usr/share/ruby-rvm /etc/rvmrc /etc/profile.d/rvm.sh
  ```
  Installing new version of RVM
  ```
  curl -L https://get.rvm.io | 
  bash -s stable --ruby --autolibs=enable --auto-dotfiles
  ```
- If you are facing errors running the `rails db:create` ensure that the socket file(i.e mysql.sock) is present in that location.   Some possible locations where it might be present is `/run/mysqld/mysqld.sock`  or `/var/lib/mysql/mysql.sock` and mention the exact location.



## Development Process 

## Step 1: Leave a comment on the GitHub issue
When you are ready to start work on a issue:

1. Let us know by leaving a comment on the issue. (Also let us know later if you are no longer working on it.)

## Step 2: Update local repo development branch
Reason: Your **local repo** *master* branch needs to stay in sync with the **project repo** *master* branch.  This is because you want to have your feature branch (to be created below) to have the latest project code before you start adding code for the feature you’re working on.

    git checkout master
    git fetch upstream
    git merge upstream/master

You should not have merge conflicts in step 3, unless you’ve made changes to your local *master* branch directly (which you should not do).

## Step 3: Create the feature branch in your local and github repos
Reason: All of your development should occur in feature branches - ideally, one branch per issue solved.  This keeps your local *master* branch clean (reflecting *upstream* master branch), allows you to abandon development approaches easily if required (e.g., simply delete the feature branch), and also allows you to maintain multiple work-in-process branches if you need to (e.g., work on a feature branch while also working on fixing a critical bug - each in its own branch).

1. Create a branch whose name contains the github issue number. For example, if you are going to work on issue (which is, say, a new feature for ‘forgot password’ management):

        git checkout -b forgot-password

    This both creates and checks out that branch in one command.  
    The feature name should provide a (short) description of the issue.

2. Push the new branch to your github repo:

        git push -u origin forgot-password

## Step 4: Develop the Feature
Develop the code for your feature (or chore/bug) as usual.  You can make interim commits to your local repo if this is a particularly large feature that takes a lot of time.

When you have completed development, make your final commit to the feature branch in your local repo.

## Step 5: Update local repo **master** branch
This should be done again in case any commits have occurred to the *master* branch in the project repo since you performed step 1.

    git checkout master
    git fetch upstream
    git merge upstream/master

## Step 6: Rebase master changes into feature branch
Now, you will need to rebase changes from the local repo *master* branch into the feature branch.

Reason: This step will add changes to your feature branch that have already been applied to the project repo *master* branch.  The result is that when you deliver your feature (that is, create a Pull Request), those changes will not be (needlessly) included in that Pull Request.

    git checkout <feature-branch-name>
    git rebase master

## Step 7: Push feature branch to your github repo
Reason: You will now push the feature branch code to github so that you can create a Pull Request against the project repo (in next step).

    git checkout <feature-branch-name>
    git push origin <feature-branch-name>

## Step 8: Create Pull Request (PR)
On the github website:

1. Go to your personal repo on Github
2. Select the *master* branch in the “Branch: “ pull-down menu
3. Click the “Compare” link

    On the next page, the “base fork” and “base” should be **CircuitVerse/CircuitVerse** and **master**, respectively.

4. Confirm “head fork: is set to **\<username\>/CircuitVerse**
5. Set “compare: “ to your feature branch name (e.g. *forgot-password*)
6. Review the file changes that are shown and confirm that all is OK.
7. Fill out details of the pull request - title, description, etc.
8. Click “Create Pull Request”





## Development Process 

## Step 1: Leave a comment on the GitHub issue
When you are ready to start work on a issue:

1. Let us know by leaving a comment on the issue. (Also let us know later if you are no longer working on it.)

## Step 2: Update local repo development branch
Reason: Your **local repo** *master* branch needs to stay in sync with the **project repo** *master* branch.  This is because you want to have your feature branch (to be created below) to have the latest project code before you start adding code for the feature you’re working on.

    git checkout master
    git fetch upstream
    git merge upstream/master

You should not have merge conflicts in step 3, unless you’ve made changes to your local *master* branch directly (which you should not do).

## Step 3: Create the feature branch in your local and github repos
Reason: All of your development should occur in feature branches - ideally, one branch per issue solved.  This keeps your local *master* branch clean (reflecting *upstream* master branch), allows you to abandon development approaches easily if required (e.g., simply delete the feature branch), and also allows you to maintain multiple work-in-process branches if you need to (e.g., work on a feature branch while also working on fixing a critical bug - each in its own branch).

1. Create a branch whose name contains the github issue number. For example, if you are going to work on issue (which is, say, a new feature for ‘forgot password’ management):

        git checkout -b forgot-password

    This both creates and checks out that branch in one command.  
    The feature name should provide a (short) description of the issue.

2. Push the new branch to your github repo:

        git push -u origin forgot-password

## Step 4: Develop the Feature
Develop the code for your feature (or chore/bug) as usual.  You can make interim commits to your local repo if this is a particularly large feature that takes a lot of time.

When you have completed development, make your final commit to the feature branch in your local repo.

## Step 5: Update local repo **master** branch
This should be done again in case any commits have occurred to the *master* branch in the project repo since you performed step 1.

    git checkout master
    git fetch upstream
    git merge upstream/master

## Step 6: Rebase master changes into feature branch
Now, you will need to rebase changes from the local repo *master* branch into the feature branch.

Reason: This step will add changes to your feature branch that have already been applied to the project repo *master* branch.  The result is that when you deliver your feature (that is, create a Pull Request), those changes will not be (needlessly) included in that Pull Request.

    git checkout <feature-branch-name>
    git rebase master

## Step 7: Push feature branch to your github repo
Reason: You will now push the feature branch code to github so that you can create a Pull Request against the project repo (in next step).

    git checkout <feature-branch-name>
    git push origin <feature-branch-name>

## Step 8: Create Pull Request (PR)
On the github website:

1. Go to your personal repo on Github
2. Select the *master* branch in the “Branch: “ pull-down menu
3. Click the “Compare” link

    On the next page, the “base fork” and “base” should be **CircuitVerse/CircuitVerse** and **master**, respectively.

4. Confirm “head fork: is set to **\<username\>/CircuitVerse**
5. Set “compare: “ to your feature branch name (e.g. *forgot-password*)
6. Review the file changes that are shown and confirm that all is OK.
7. Fill out details of the pull request - title, description, etc.
8. Click “Create Pull Request”




## Production Specific Instructions

```
bundle install --without development test
RAILS_ENV=production bundle exec rake assets:precompile
bundle exec sidekiq -e production -q default -q mailers -d -L tmp/sidekiq.log` (In production)
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) for details.
