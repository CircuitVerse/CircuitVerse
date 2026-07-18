# frozen_string_literal: true

module SimulatorHelper
  def return_image_file(data_url)
    str = data_url[("data:image/jpeg;base64,".length)..]
    if str.to_s.empty?
      path = Rails.public_path.join("images/default.png")
      image_file = File.open(path, "rb") # rubocop:disable Style/FileOpen

    else
      jpeg       = Base64.decode64(str)
      image_file = File.new("tmp/preview_#{Time.zone.now.to_f.to_s.sub('.', '')}.jpeg", "wb")
      image_file.write(jpeg)
    end
    image_file
  end

  def parse_image_data_url(data_url)
    str = data_url[("data:image/jpeg;base64,".length)..]
    if str.to_s.empty?
      image_file = nil
    else
      jpeg       = Base64.decode64(str)
      image_file = StringIO.new(jpeg)
    end

    image_file
  end

  def check_to_delete(data_url)
    !data_url[("data:image/jpeg;base64,".length)..].to_s.empty?
  end

  def sanitize_data(project, data)
    return (data.is_a?(String) ? data : data.to_json) if project&.assignment_id.blank? || data.blank?

    data_hash = data.is_a?(String) ? Oj.safe_load(data) : data
    saved_restricted_elements = Oj.safe_load(project.assignment.restrictions)
    scopes = data_hash["scopes"] || []

    parsed_scopes = scopes.each_with_object([]) do |scope, new_scopes|
      restricted_elements_used = []

      saved_restricted_elements.each do |element|
        restricted_elements_used.push(element) if scope[element].present?
      end

      scope["restrictedCircuitElementsUsed"] = restricted_elements_used
      new_scopes.push(scope)
    end

    data_hash["scopes"] = parsed_scopes
    data_hash.to_json
  end
end
