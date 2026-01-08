# frozen_string_literal: true

class CleanUpInvalidTags < ActiveRecord::Migration[7.1]
  def up
    remove_empty_tags
    fix_invalid_tag_names
    cleanup_taggings
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

    def remove_empty_tags
      Tag.where("name IS NULL OR name = '' OR TRIM(name) = ''").destroy_all
    end

    def fix_invalid_tag_names
      Tag.find_each do |tag|
        next if tag.name.blank?
        next if tag.name.valid_encoding?

        clean_name = tag.name
                        .encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
                        .strip
                        .delete("\u0000")

        if clean_name.present?
          tag.update!(name: clean_name)
        else
          tag.destroy
        end
      end
    end

    def cleanup_taggings
      safety_assured do
        remove_orphaned_taggings
        remove_duplicate_taggings
      end
    end

    def remove_orphaned_taggings
      execute <<~SQL.squish
        DELETE FROM taggings
        WHERE tag_id NOT IN (SELECT id FROM tags)
      SQL
    end

    def remove_duplicate_taggings
      execute <<~SQL.squish
        DELETE FROM taggings a USING (
          SELECT MIN(id) AS id, project_id, tag_id
          FROM taggings
          GROUP BY project_id, tag_id
          HAVING COUNT(*) > 1
        ) b
        WHERE a.project_id = b.project_id
          AND a.tag_id = b.tag_id
          AND a.id <> b.id
      SQL
    end
end
