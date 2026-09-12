# frozen_string_literal: true

class RequestEncodingSanitizer
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Encoding::CompatibilityError, Encoding::UndefinedConversionError
    [
      400,
      { "Content-Type" => "application/json" },
      ['{"errors":[{"status":"400","title":"Bad Request","detail":"Invalid character encoding in request"}]}']
    ]
  end
end
