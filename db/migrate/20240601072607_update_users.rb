class UpdateUsers < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_table :users do |t|
        t.jsonb :submission_history, array: true, default: []
        t.boolean :public, default: true
        t.boolean :question_bank_moderator, default: false
      end
    end
  end
end
