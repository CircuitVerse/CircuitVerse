# frozen_string_literal: true

module SimulatorHelper
  def parse_image_data_url(data_url)
    str = data_url[("data:image/jpeg;base64,".length)..]
    return nil if str.to_s.empty?

    jpeg = Base64.decode64(str)
    StringIO.new(jpeg)
  end

  def sanitize_data(project, data)
    data = data.to_json if data.is_a?(ActionController::Parameters)
    return data if project&.assignment_id.blank? || data.blank?

    data = Oj.safe_load(data)
    saved_restricted_elements = Oj.safe_load(project.assignment.restrictions)
    scopes = data["scopes"] || []

    parsed_scopes = scopes.each_with_object([]) do |scope, new_scopes|
      restricted_elements_used = []

      saved_restricted_elements.each do |element|
        restricted_elements_used.push(element) if scope[element].present?
      end

      scope["restrictedCircuitElementsUsed"] = restricted_elements_used
      new_scopes.push(scope)
    end

    data["scopes"] = parsed_scopes
    data.to_json
  end
end
