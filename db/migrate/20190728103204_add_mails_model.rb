class AddMailsModel < ActiveRecord::Migration[5.1]
  def change
    create_table :custom_mails do |t|
      t.text :subject
      t.text :content
      t.timestamps
    end

    add_reference :custom_mails, :user, foreign_key: true
  end
end
