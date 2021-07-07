## How To Setup CircuitVerse on Ubuntu [Quickstart]

### Introduction
CircuitVerse is a web-based simulation software for creating and testing digital circuits. 
The easy drag and drop feature makes it easier and a fun way to learn about logic circuits and also compatible to be used by teachers as well as students.
From simple gates to complex sequential circuits, plot timing diagrams, automatic circuit generation, explore standard ICs, and much more, CircuitVerse has got you covered.
It also lets the user store and access the previously built circuits to build yet more complex circuits and generate truth tables for the constructed circuits

![CircuitVerse Logo](https://github.com/CircuitVerse/CircuitVerse/raw/master/public/img/cvlogo.svg?sanitize=true)

This tutorial will walk you through setting up and configuring the development environment for [CircuitVerse](https://circuitverse.org/) on an Ubuntu server. 
For a more detailed version of this tutorial, with better explanations of each step, please read along.

***

### Pre-requitses
- Ubuntu 18.04 or above
- Git 2.26.2 Installed [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-git-on-ubuntu-18-04-quickstart)
- Ruby Version: ruby-2.6.5 [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-and-set-up-a-local-programming-environment-on-ubuntu-16-04)
- Rails Version: Rails 6.0.1 [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-18-04)
- PostgreSQL Version: 9.5 [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-18-04)
- Yarn [Tutorial](https://linuxize.com/post/how-to-install-yarn-on-ubuntu-18-04/)
- Docker [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04)
- Redis [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-18-04)
- Imagemagick [Tutorial](https://linuxconfig.org/how-to-install-imagemagick-7-on-ubuntu-18-04-linux)
***

## Step 1 — 🍽️ Fork From CircuitVerse
To contribute, first fork the original repository by navigating at the top of the repository in GitHub.

![fork](https://user-images.githubusercontent.com/42115530/81844206-5c8d6b80-956c-11ea-998d-beac8ee1468d.png)

## Step 2 — :floppy_disk: Clone the repo
Clone the forked repository into your local machine using the following command:
```
$ git clone https://github.com/your-username/CircuitVerse.git
$ cd CircuitVerse
```
You can :clipboard: copy the URL by using the green “Clone or download” button from your repository page that you just forked from the original repository page. Once you click the button, you’ll be able to copy the URL by clicking the binder button next to the URL:

![clone](https://user-images.githubusercontent.com/42115530/81844918-6ebbd980-956d-11ea-855a-87cff1a6bfbf.png)

## Step 3 — 🔨 Install dependencies

```
$ bundle install
```
You might get an error stating:
```
An error occured while installing pg (1.1.4), and Bundler cannot continue.
Make sure that `gem install pg -v '1.1.4' --source 'https://rubygems.org/' succeeds before bundling.

In Gemfile:
pg
```

To run it correctly, try this:
```
$ sudo apt-get install postgresql
$ sudo apt-get install libpq-dev
```
Then
```
$ gem install pg
```
then
```
$ bundle install
```

## Step 4 — :rocket: Configure your PostgreSQL database
Copy `config/database.example.yml` and paste into `config/database.yml` and update the Postgres credentials need to be updated to your currently running database.

!](https://user-images.githubusercontent.com/42115530/81856035-ceba7c00-957d-11ea-8aa8-5eef7233f1c1.PNG)

## NOTE:
Make sure you have updated the username and password to your postgres username and password as shown below.
```
  username: 'yourusername'
  password: 'yourpassword'
```

![rails db](https://user-images.githubusercontent.com/42115530/81952842-928e2680-9624-11ea-86c1-f11611eccbfa.PNG)


## Step 5 — :bulb: Create Database
```
$ rails db:create
```
![db-create](https://user-images.githubusercontent.com/42115530/81975079-23c0c580-9644-11ea-9422-fa09820440b9.PNG) 

You might get an error stating `rails aborted`, so, try any of these:
- ensure that you have installed npm correctly
- ensure that you have installed nodejs correctly
- ensure that you have installed yarn correctly
> In case, you get the following error:
```
error @rails/webpacker@4.2.2: The engine "node" is incompatible with this module. Expected version ">=8.16.0". Got "8.10.0"
error Found incompatible module.
```
then, try this:
```
$ rm yarn.lock
$ bundle
$ sudo npm cache clean -f
$ sudo npm install -g n
$ sudo n stable
$ sudo apt-get install --reinstall nodejs-legacy
$ yarn install
```
## Step 6 — :eyes: Run Migrations
```
$ rails db:migrate
```
You might encounter an error:
```
Redis::CommandError in LogixController#index

```
![error](https://user-images.githubusercontent.com/42115530/81975938-69ca5900-9645-11ea-8805-3964a317789f.PNG)

To fix this, try:
- ensure that your redis server is up and running

```
$ sudo systemctl start redis
$ sudo systemctl status redis
```
You should see something that looks like this:

```
Output
● redis.service - Redis Server
   Loaded: loaded (/etc/systemd/system/redis.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2016-05-11 14:38:08 EDT; 1min 43s ago
  Process: 3115 ExecStop=/usr/local/bin/redis-cli shutdown (code=exited, status=0/SUCCESS)
 Main PID: 3124 (redis-server)
    Tasks: 3 (limit: 512)
   Memory: 864.0K
      CPU: 179ms
   CGroup: /system.slice/redis.service
           └─3124 /usr/local/bin/redis-server 127.0.0.1:6379       

. . .
```
![redis](https://user-images.githubusercontent.com/42115530/81975452-ae092980-9644-11ea-84c7-8984ccc5951f.PNG)

- ensure that you have enabled Redis to Start at Boot

```
$ sudo systemctl enable redis
```
Output should look like this:
```
Created symlink from /etc/systemd/system/multi-user.target.wants/redis.service to /etc/systemd/system/redis.service.
```
- comment requirepass (line 480 mostly) in redis.conf file if uncommented. 

```
$ sudo nano /etc/redis/redis.conf
```
and then restart the redis server using the following command:
```
$ sudo systemctl restart redis.service
```

### NOTE:
If you have configured a password for your redis-server, try:

```
$ redis-cli -h <host.domain.com> -p <port> -a <yourpassword>
```

> Learn more about configuring your redis passoword. [Tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-redis-on-ubuntu-18-04)

## Step 7 — :zap: Seed the database
To seed the database with some sample data, run 
```
$ bundle exec rake db:seed.
```
![seed](https://user-images.githubusercontent.com/42115530/81976923-ddb93100-9646-11ea-98bb-fcb467f4348a.PNG)

The admin credentials after seeding will be:
```
User: Admin
Email: admin@circuitverse.org
Password: password
```
## Step 8 — :tada: Run Rails Server
To run the rails server:
```
$ rails s -b 127.0.0.1 -p 8080
```
![runserver1](https://user-images.githubusercontent.com/42115530/81977414-9f704180-9647-11ea-9de4-066328ceaef0.PNG)

The local development server will be started at `127.0.0.1:8080` in your web browser. Open the browser to see the website.

![final](https://user-images.githubusercontent.com/42115530/81977424-a1d29b80-9647-11ea-916d-4dc9fc3f01d5.PNG)

***
### :confetti_ball: Congratulations!!! We are done. Now, you are all set to make your create, contribute and learn.
### For more info
See [`SETUP.md`](https://github.com/CircuitVerse/CircuitVerse/blob/master/SETUP.md) and [`CONTRIBUTING.md`](https://github.com/CircuitVerse/CircuitVerse/blob/master/CONTRIBUTING.md) to know more.

### Create:memo:, Contribute:octocat:, Learn:mortar_board: and succeed:trophy: with CircuitVerse!!! 
***
