# frozen_string_literal: true

class ProjectDatum < ApplicationRecord
  belongs_to :project

  before_validation :ensure_unique_circuit_name_per_user, on: :create

  private

  def ensure_unique_circuit_name_per_user
    return if project.nil? || data.blank?
    
    begin
      parsed_data = JSON.parse(data)
    rescue JSON::ParserError
      errors.add(:data, "must be valid JSON")
      throw(:abort)
    end
  
    return if parsed_data["name"].blank?
  
    user_id = project.author_id
    base_name = parsed_data["name"].gsub(/\s\(\d+\)$/, "").strip
    
    # Fetch existing names once
    existing_names = ProjectDatum.joins(:project)
                                 .where(projects: { author_id: user_id })
                                 .where("(project_data.data::jsonb ->> 'name') LIKE ?", "#{base_name}%")
                                 .where.not(id: id)
                                 .pluck(Arel.sql("project_data.data::jsonb ->> 'name'"))
                                 .to_set
  
    final_name = base_name
    counter = 1
    while existing_names.include?(final_name)
      final_name = "#{base_name} (#{counter})"
      counter += 1
    end
  
    if parsed_data["name"] != final_name
      parsed_data["name"] = final_name
      self.data = parsed_data.to_json
    end
  end
end