class AddAvatarToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :image_preview, :string
  end
end
