# frozen_string_literal: true

module SimulatorHelper
  IMAGE_DATA_URL_PREFIX = "data:image/jpeg;base64,"
  BASE64_FORMAT = %r{\A[A-Za-z0-9+/]*={0,2}\z}

  def return_image_file(data_url)
    str = valid_base64_payload(data_url)
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
    str = valid_base64_payload(data_url)
    if str.to_s.empty?
      image_file = nil
    else
      jpeg       = Base64.decode64(str)
      image_file = StringIO.new(jpeg)
    end

    image_file
  end

  def check_to_delete(data_url)
    !valid_base64_payload(data_url).to_s.empty?
  end

  def attach_circuit_preview(project, image_file)
    return unless image_file

    project.circuit_preview.attach(
      io: image_file,
      filename: "preview_#{Time.zone.now.to_f.to_s.sub('.', '')}.jpeg",
      content_type: "image/jpeg"
    )
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

  private

    def valid_base64_payload(data_url)
      return nil unless data_url.is_a?(String) && data_url.start_with?(IMAGE_DATA_URL_PREFIX)

      payload = data_url[IMAGE_DATA_URL_PREFIX.length..]
      payload if payload.present? && (payload.length % 4).zero? && BASE64_FORMAT.match?(payload)
    end
end
