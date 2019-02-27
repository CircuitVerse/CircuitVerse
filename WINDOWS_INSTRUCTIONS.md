# Setting Up the Project on Windows

Detailed Instructions for setting up this project on windows

## Versions
<ul>
<li>Ruby Version: ruby-2.5.1</li>
 <li>Rails Version: Rails 5.1.6</li>
 <li>PostgreSQL Version: 9.5</li>
 <li>MYSQL Server</li>
 </ul>

### Prerequisites

What things you need to install the software and how to install them
<ul>
<li>git-bash : [Git Bash](https://git-scm.com/)</li>
<li>Ruby  :    [Rails Installer ](https://s3.amazonaws.com/railsinstaller/Windows/railsinstaller-3.4.0.exe)</li>
<li>PostgreSQL : [PostgreSQL](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)</li>
<li>Mysql Server : [Xampp](https://www.apachefriends.org/download.html)</li>
  </ul>

###### Packages Included in the rails Installer:
<ul>
  <li>Ruby 2.3.3</li>
  <li>Rails 5.1</li>
  <li>Bundler</li>
  <li>Git</li>
  <li>Sqlite</li>
  <li>TinyTDS</li>
  <li>SQL Server Support</li>
  <li>DevKit</li>
</ul>


###### Packages Included in the Postgresql Installer:


<ul>
  <li>PostgreSQL server</li>
  <li>pgAdmin</li>
</ul>


### Installing

A step by step guide that tells you how to get a development environment up and  running

Open the Rails Installer

```
Folow the on screen instructions

**Check the option to add exceutables of rails in the PATH**

```

Migrate to C://sites Folder
and open Git bash There


## Running the tests

To check if Ruby is Properly Installed type the following command in git bash

```
ruby -v

```
This should display the current installed ruby version


To check if Rails is Properly Installed type the following command in git bash

```
rails -v

```
This should display the current installed rails version


To check if  Ruby Gems is Properly Installed type the following command in git bash

```
gem -v

```
This should display the current installed Ruby Gems version

To check if  Bundler is Properly Installed type the following command in git bash

```
bundler -v

```
This should display the current installed Bundler version




## Install PostgreSQL
<ul>
<li>After installing the Microsoft c++ Runtime environment settings you will be welcomed by the PostgreSQL setup wizard</li>
<li>After a few prompts it will ask you to set a password for the super user - GO ahead and set it</li>
  <li>Next it will ask you the port on which to listen by default it is - 5432</li>
  <li>go ahead and complete the installation</li>
</ul>
**The default username is postgres**


## Install Xampp 
<ul>
  <li>After Installing Xampp Start the Apache and Mysql Servers</li>
  <li>Redirect to localhost and set up a **MYSQL USERNAME and PASSWORD**</li>
</ul>

### Setting up the application

Migrate to the C:/Sites folder and Clone the CircuitVerse Repository
Open Gitbash and run the Following commands

```
bundle install

```
Wait for the process to complete

Next navigate to the C:\Sites\CircuitVerse\config and copy the database.yml.example file and rename it to databse.yml
<ul>
<li>Next under the default section Setup your Mysql Username and Password</li>
<li>Next under the Production  section Setup your PostgreSQL Username and Password</li>
 
</ul>
### Final Process

Run the following Commands

```
rails db:create

rails db:migrate


```
Finally run the server using  rails s -b 127.0.0.1 -p 8080
