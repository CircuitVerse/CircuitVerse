# This migration comes from commontator (originally 11)
class AddReplyingToComments < ActiveRecord::Migration[6.0]
  def change
    add_reference :commontator_comments, :parent, foreign_key: {
      to_table: :commontator_comments, on_update: :restrict, on_delete: :cascade
    }
  end
end
