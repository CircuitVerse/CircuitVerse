# Setting Up the Project on Windows

Detailed Instructions for setting up this project on windows

## Versions
+ Ruby Version: ruby-2.5.1
+ Rails Version: Rails 5.1.6
+ PostgreSQL Version: 9.5
+ MYSQL Server


## Prerequisites

What things you need to install the software and how to install them

+ git-bash : [Git Bash](https://git-scm.com/)
+ Ruby  :    [Rails Installer ](https://s3.amazonaws.com/railsinstaller/Windows/railsinstaller-3.4.0.exe)
+ PostgreSQL : [PostgreSQL](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)
+ Mysql Server : [Xampp](https://www.apachefriends.org/download.html)


**Packages Included in the rails Installer:**

  + Ruby 2.3.3
  + Rails 5.1
  + Bundler
  + Git
  + Sqlite
  + TinyTDS
  + SQL Server Support
  + DevKit


**Packages Included in the Postgresql Installer:**

  + PostgreSQL server
  + pgAdmin

## Installing

A step by step guide that tells you how to get a development environment up and  running

Open the Rails Installer

```
Folow the on screen instructions

Check the option to add exceutables of rails in the PATH

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

+ After installing the Microsoft c++ Runtime environment settings you will be welcomed by the PostgreSQL setup wizard
+ After a few prompts it will ask you to set a password for the super user - GO ahead and set it
+ Next it will ask you the port on which to listen by default it is - 5432
+ go ahead and complete the installation
**The default username is postgres**


## Install Xampp 

  + After Installing Xampp Start the Apache and Mysql Servers</li>
  + Redirect to localhost and set up a **MYSQL USERNAME and PASSWORD**

## Setting up the application

Migrate to the C:/Sites folder and Clone the CircuitVerse Repository
Open Gitbash and run the Following commands

```
bundle install

```
Wait for the process to complete

+ Next navigate to the C:\Sites\CircuitVerse\config and copy the database.yml.example file and rename it to databse.yml
+ Next under the default section Setup your Mysql Username and Password
+ Next under the Production  section Setup your PostgreSQL Username and Password
 


## Final Process

Run the following Commands

```
rails db:create

rails db:migrate

rails s -b 127.0.0.1 -p 8080

```
Your Application is then Up and Running
