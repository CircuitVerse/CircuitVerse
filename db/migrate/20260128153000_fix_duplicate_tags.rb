class FixDuplicateTags < ActiveRecord::Migration[7.0]
  class MigrationTag < ApplicationRecord
    self.table_name = "tags"
  end

  class MigrationTagging < ApplicationRecord
    self.table_name = "taggings"
  end

  def up
    duplicates = MigrationTag.group(:name).having("count(*) > 1").pluck(:name)

    duplicates.each do |name|
      tags = MigrationTag.where(name: name).order(created_at: :asc)
      master_tag = tags.first
      duplicates_to_merge = tags[1..-1]

      duplicates_to_merge.each do |dup_tag|
        MigrationTagging.where(tag_id: dup_tag.id).find_each do |tagging|
          if MigrationTagging.exists?(tag_id: master_tag.id, project_id: tagging.project_id)
            tagging.destroy
          else
            tagging.update(tag_id: master_tag.id)
          end
        end
        dup_tag.destroy
      end
    end

    add_index :tags, "LOWER(name)", unique: true, name: "index_tags_on_lower_name"
  end

  def down
    remove_index :tags, name: "index_tags_on_lower_name"
  end
end
