# frozen_string_literal: true

module Api::V1::SimulatorHelper
  def return_image_file(data_url)
    str = data_url[23..]
    if str.to_s.empty?
      path = Rails.public_path.join("images/default.png")
      image_file = File.open(path, "rb")
    else
      jpeg = Base64.decode64(str)
      image_file = File.new("tmp/preview_#{Time.zone.now.to_f.to_s.sub('.', '')}.jpeg", "wb")
      image_file.write(jpeg)
    end

    image_file
  end

  def check_to_delete(data_url)
    !data_url[23..].to_s.empty?
  end

  def sanitize_data(project, data)
    return data if project&.assignment_id.blank? || data.blank?

    data = Oj.safe_load(data)
    saved_restricted_elements = Oj.safe_load(project.assignment.restrictions)
    scopes = data["scopes"] || []

    data["scopes"] = parse_scopes(scopes, saved_restricted_elements)
    data.to_json
  end

  private

    def parse_scopes(scopes, saved_restricted_elements)
      scopes.each_with_object([]) do |scope, new_scopes|
        scope["restrictedCircuitElementsUsed"] = find_restricted_elements_used(scope, saved_restricted_elements)
        new_scopes.push(scope)
      end
    end

    def find_restricted_elements_used(scope, saved_restricted_elements)
      saved_restricted_elements.each_with_object([]) do |element, restricted_elements_used|
        restricted_elements_used.push(element) if scope[element].present?
      end
    end
end
