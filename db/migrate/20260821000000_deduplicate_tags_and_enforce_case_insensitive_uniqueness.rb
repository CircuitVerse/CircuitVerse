# frozen_string_literal: true

class DeduplicateTagsAndEnforceCaseInsensitiveUniqueness < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      remove_blank_tags
      deduplicate_tags
      deduplicate_taggings
    end

    add_index :tags, "LOWER(name)", unique: true,
                                    algorithm: :concurrently,
                                    name: "index_tags_on_lower_name"
    add_index :taggings, %i[project_id tag_id], unique: true,
                                                algorithm: :concurrently,
                                                name: "index_taggings_on_project_id_and_tag_id"
    add_check_constraint :tags, "name IS NOT NULL", name: "tags_name_null", validate: false
    validate_check_constraint :tags, name: "tags_name_null"
  end

  def down
    remove_check_constraint :tags, name: "tags_name_null"
    remove_index :taggings, name: "index_taggings_on_project_id_and_tag_id",
                            algorithm: :concurrently, if_exists: true
    remove_index :tags, name: "index_tags_on_lower_name",
                        algorithm: :concurrently, if_exists: true
  end

  private

    def remove_blank_tags
      blank_tag_ids = select_values(<<~SQL.squish)
        SELECT id FROM tags WHERE name IS NULL OR TRIM(name) = ''
      SQL
      return if blank_tag_ids.empty?

      execute("DELETE FROM taggings WHERE tag_id IN (#{blank_tag_ids.join(',')})")
      execute("DELETE FROM tags WHERE id IN (#{blank_tag_ids.join(',')})")
    end

    def deduplicate_tags
      duplicate_groups = select_rows(<<~SQL.squish)
        SELECT LOWER(TRIM(name)), ARRAY_AGG(id ORDER BY id) FROM tags
        GROUP BY LOWER(TRIM(name)) HAVING COUNT(*) > 1
      SQL

      duplicate_groups.each do |row|
        ids = row.last
        ids = ids.tr("{}", "").split(",").map(&:to_i) if ids.is_a?(String)
        merge_tags(ids.first, ids.drop(1))
      end

      execute("UPDATE tags SET name = TRIM(name) WHERE name <> TRIM(name)")
    end

    def merge_tags(canonical_id, duplicate_ids)
      execute(<<~SQL.squish)
        UPDATE taggings SET tag_id = #{canonical_id}
        WHERE tag_id IN (#{duplicate_ids.join(',')})
        AND NOT EXISTS (
          SELECT 1 FROM taggings existing
          WHERE existing.project_id = taggings.project_id
          AND existing.tag_id = #{canonical_id}
        )
      SQL
      execute("DELETE FROM taggings WHERE tag_id IN (#{duplicate_ids.join(',')})")
      execute("DELETE FROM tags WHERE id IN (#{duplicate_ids.join(',')})")
    end

    def deduplicate_taggings
      execute(<<~SQL.squish)
        DELETE FROM taggings WHERE id NOT IN (
          SELECT MIN(id) FROM taggings GROUP BY project_id, tag_id
        )
      SQL
    end
end
