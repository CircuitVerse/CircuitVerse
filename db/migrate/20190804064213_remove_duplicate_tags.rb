class RemoveDuplicateTags < ActiveRecord::Migration[5.1]
  def change
    duplicate_row_values = Tagging.select('project_id, tag_id, count(*)').group('project_id, tag_id').having('count(*) > 1').pluck(:project_id, :tag_id)
    duplicate_row_values.each do |project_id, tag_id|
      Tagging.where(project_id: project_id, tag_id: tag_id).order(id: :desc)[1..-1].map(&:destroy)
    end
  end
end