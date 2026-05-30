class ValidateForeignKeysForums < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :forum_posts, :users
    validate_foreign_key :forum_threads, :users 
  end
end
