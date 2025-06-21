# frozen_string_literal: true

module SimulatorHelper
  # @param [String] data_url
  # @return [File] Image file
  def return_image_file(data_url)
    str = data_url[("data:image/jpeg;base64,".length)..]
    if str.to_s.empty?
      path = Rails.public_path.join("images/default.png")
      image_file = File.open(path, "rb")

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

  # @param [String] data_url
  # @return [Boolean] True if data_url is not empty
  def check_to_delete(data_url)
    !data_url[("data:image/jpeg;base64,".length)..].to_s.empty?
  end

  # @param [String] data
  # @return [String] Sanitized data
  def sanitize_data(project, data)
    return data if project&.assignment_id.blank? || data.blank?

    # @type [Hash]
    data = Oj.safe_load(data)
    # @type [Array]
    saved_restricted_elements = Oj.safe_load(project.assignment.restrictions)
    # @type [Array]
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
