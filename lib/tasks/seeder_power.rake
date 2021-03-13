# frozen_string_literal: true

namespace :db do
  namespace :seed do
    Dir[Rails.root.join("db", "seeds", "*.rb")].each do |filename|
      task_name = File.basename(filename, ".rb")
      desc "Seed #{task_name}, based on the file with the same name in `db/seeds/*.rb`"
      task task_name.to_sym => :environment do
        load(filename) if File.exist?(filename)
      end
    end
  end
end
