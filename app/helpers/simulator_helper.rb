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
    data = data.to_json if data.is_a?(ActionController::Parameters)
    return data if project&.assignment_id.blank? || data.blank?

    parsed_data = safe_parse_json(data)
    return data if parsed_data.nil?

    saved_restricted_elements = safe_parse_json(project.assignment.restrictions) || []
    scopes = parsed_data["scopes"] || []

    parsed_scopes = scopes.each_with_object([]) do |scope, new_scopes|
      restricted_elements_used = []

      saved_restricted_elements.each do |element|
        restricted_elements_used.push(element) if scope[element].present?
      end

      scope["restrictedCircuitElementsUsed"] = restricted_elements_used
      new_scopes.push(scope)
    end

    parsed_data["scopes"] = parsed_scopes
    parsed_data.to_json
  end

  private

    # Attempts to parse a JSON string using Oj first, falling back to the
    # standard JSON library. Returns nil (and logs a warning) if both fail,
    # so callers can return the raw data unmodified rather than raising.
    def safe_parse_json(json_string)
      sanitized = sanitize_json_string(json_string.to_s)
      Oj.safe_load(sanitized)
    rescue Oj::ParseError, Oj::Error
      begin
        JSON.parse(sanitized)
      rescue JSON::ParserError => e
        Rails.logger.warn("[SimulatorHelper] Could not parse JSON: #{e.message.truncate(200)}")
        nil
      end
    end

    # Replaces invalid JSON escape sequences (backslash not followed by a
    # recognised escape character) with an escaped backslash so that
    # downstream JSON parsers do not reject the payload.
    # Valid single-char escapes: \" \\ \/ \b \f \n \r \t
    # Valid Unicode escapes:     \uXXXX
    def sanitize_json_string(str)
      str.gsub(/\\(?!["\\/bfnrtu]|u[0-9a-fA-F]{4})/, "\\\\\\\\")
    end
end
