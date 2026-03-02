# frozen_string_literal: true

class ProjectDatum < ApplicationRecord
  belongs_to :project

  before_validation :ensure_unique_circuit_name_per_user, on: :create

  private

    def ensure_unique_circuit_name_per_user
      return if project.nil? || data.blank?

      parsed_data = begin
        JSON.parse(data)
      rescue StandardError
        {}
      end
      return if parsed_data["name"].blank?

      user_id   = project.author_id
      base_name = parsed_data["name"].gsub(/\s\(\d+\)$/, "").strip
      counter   = 1
      new_name  = base_name

      while ProjectDatum
            .joins(:project)
            .where(projects: { author_id: user_id })
            .where("(project_data.data::jsonb ->> 'name') = ?", new_name)
            .where.not(id: id)
            .exists?

        new_name = "#{base_name} (#{counter})"
        counter += 1
      end

      parsed_data["name"] = new_name
      self.data = parsed_data.to_json
    end
end
