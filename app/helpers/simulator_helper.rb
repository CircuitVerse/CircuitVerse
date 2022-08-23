# frozen_string_literal: true

module SimulatorHelper
  def return_image_file(data_url)
    str = data_url[("data:image/jpeg;base64,".length)..]
    if str.to_s.empty?
      path = Rails.root.join("public/images/default.png")
      image_file = File.open(path, "rb")

    else
      jpeg       = Base64.decode64(str)
      image_file = File.new("tmp/preview_#{Time.zone.now.to_f.to_s.sub('.', '')}.jpeg", "wb")
      image_file.write(jpeg)
    end

    image_file
  end

  def check_to_delete(data_url)
    !data_url[("data:image/jpeg;base64,".length)..].to_s.empty?
  end

  def sanitize_data(project, data)
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
