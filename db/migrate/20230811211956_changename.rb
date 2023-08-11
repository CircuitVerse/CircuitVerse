class Changename < ActiveRecord::Migration[7.0]
  def change
    user = User.first
    user.name = "vaibhavupreti"
    user.save!
  end
end
