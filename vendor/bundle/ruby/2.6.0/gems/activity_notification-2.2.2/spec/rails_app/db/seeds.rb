# coding: utf-8
# This file is seed file for test data on development environment.

def clean_database
  models = [Comment, Article, Admin, User]
  if ENV['AN_USE_EXISTING_DYNAMODB_TABLE']
    ActivityNotification::Notification.where('id.not_null': true).delete_all
    ActivityNotification::Subscription.where('id.not_null': true).delete_all
  else
    models.concat([ActivityNotification::Notification, ActivityNotification::Subscription])
  end
  models.each do |model|
    model.delete_all
  end
end

def reset_pk_sequence
  models = [Comment, Article, Admin, User]
  if ActivityNotification.config.orm == :active_record
    models.concat([ActivityNotification::Notification, ActivityNotification::Subscription])
  end
  case ENV['AN_TEST_DB']
  when nil, '', 'sqlite'
    ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 0")
  when 'mysql'
    models.each do |model|
      ActiveRecord::Base.connection.execute("ALTER TABLE #{model.table_name} AUTO_INCREMENT = 1")
    end
  when 'postgresql'
    models.each do |model|
      ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
    end
  when 'mongodb'
  else
    raise "#{ENV['AN_TEST_DB']} as AN_TEST_DB environment variable is not supported"
  end
end

clean_database
puts "* Cleaned database"

reset_pk_sequence
puts "* Reset sequences for primary keys"

['Ichiro', 'Stephen', 'Klay', 'Kevin'].each do |name|
  user = User.new(
    email:                 "#{name.downcase}@example.com",
    password:              'changeit',
    password_confirmation: 'changeit',
    name:                  name,
  )
  user.skip_confirmation!
  user.save!
end
puts "* Created #{User.count} user records"

['Ichiro'].each do |name|
  user = User.find_by(name: name)
  Admin.create(
    user: user,
    phone_number: ENV['OPTIONAL_TARGET_AMAZON_SNS_PHONE_NUMBER'],
    slack_username: ENV['OPTIONAL_TARGET_SLACK_USERNAME']
  )
end
puts "* Created #{Admin.count} admin records"

User.all.each do |user|
  article = user.articles.create(
    title: "#{user.name}'s first article",
    body:  "This is the first #{user.name}'s article. Please read it!"
  )
  article.notify :users, send_email: false
end
puts "* Created #{Article.count} article records"
notifications = ActivityNotification::Notification.filtered_by_type("Article")
puts "** Generated #{ActivityNotification::Notification.filtered_by_type("Article").count} notification records for new articles"
puts "*** #{ActivityNotification::Notification.filtered_by_type("Article").filtered_by_target_type("User").count} notifications as #{ActivityNotification::Notification.filtered_by_type("Article").filtered_by_target_type("User").group_owners_only.count} groups to users"
puts "*** #{ActivityNotification::Notification.filtered_by_type("Article").filtered_by_target_type("Admin").count} notifications as #{ActivityNotification::Notification.filtered_by_type("Article").filtered_by_target_type("Admin").group_owners_only.count} groups to admins"

Article.all.each do |article|
  User.all.each do |user|
    comment = article.comments.create(
      user: user,
      body:  "This is the first #{user.name}'s comment to #{article.user.name}'s article."
    )
    comment.notify :users, send_email: false
  end
end
puts "* Created #{Comment.count} comment records"
notifications = ActivityNotification::Notification.filtered_by_type("Comment")
puts "** Generated #{ActivityNotification::Notification.filtered_by_type("Comment").count} notification records for new comments"
puts "*** #{ActivityNotification::Notification.filtered_by_type("Comment").filtered_by_target_type("User").count} notifications as #{ActivityNotification::Notification.filtered_by_type("Comment").filtered_by_target_type("User").group_owners_only.count} groups to users"
puts "*** #{ActivityNotification::Notification.filtered_by_type("Comment").filtered_by_target_type("Admin").count} notifications as #{ActivityNotification::Notification.filtered_by_type("Comment").filtered_by_target_type("Admin").group_owners_only.count} groups to admins"

puts "Created ActivityNotification test records!"
