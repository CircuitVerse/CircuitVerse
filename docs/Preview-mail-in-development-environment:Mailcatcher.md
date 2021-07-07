# MAILCATCHER

MailCatcher runs a simple SMTP server which catches any message sent to it to display in a web interface. Here as soon as we run mailcatcher and then on Server if we click on any Email service like Forgot Password or Email Confirmation then it will be catched easily using this.

# SETUP

1. As the gem is present in our gemfile so we just need to run `bundle install` to get it installed along with other dependencies.
2. Then Run `mailcatcher` .
3. Now Try sending an email through smtp://localhost:1025.
4. You now can see your email at http://localhost:1080

For help run `mailcatcher --help`.
