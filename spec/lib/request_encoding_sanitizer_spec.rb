# frozen_string_literal: true

require "rails_helper"
require_relative "../../app/lib/request_encoding_sanitizer"

RSpec.describe RequestEncodingSanitizer do
  let(:app) { ->(env) { [200, { "Content-Type" => "text/plain" }, ["OK"]] } }
  let(:middleware) { described_class.new(app) }

  it "passes through normal requests" do
    status, _, body = middleware.call({})
    expect(status).to eq(200)
    expect(body).to eq(["OK"])
  end

  it "catches Encoding::CompatibilityError and returns 400 Bad Request" do
    failing_app = ->(_env) { raise Encoding::CompatibilityError, "incompatible character encodings: UTF-16LE and UTF-8" }
    status, headers, body = described_class.new(failing_app).call({})

    expect(status).to eq(400)
    expect(headers["Content-Type"]).to eq("application/json")
    expect(body.first).to include("Invalid character encoding in request")
  end

  it "catches Encoding::UndefinedConversionError and returns 400 Bad Request" do
    failing_app = ->(_env) { raise Encoding::UndefinedConversionError, "undefined conversion" }
    status, headers, body = described_class.new(failing_app).call({})

    expect(status).to eq(400)
    expect(headers["Content-Type"]).to eq("application/json")
    expect(body.first).to include("Invalid character encoding in request")
  end
end
