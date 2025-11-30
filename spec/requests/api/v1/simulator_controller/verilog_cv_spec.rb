# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SimulatorController, type: :request do
  describe "POST /api/v1/simulator/verilogcv" do
    let(:code) { "sample_code" }
    let(:yosys_url) { "#{ENV.fetch('YOSYS_PATH', 'http://127.0.0.1:3040')}/getJSON" }
    let(:yosys_response) { { "data" => "response_from_yosys" } }

    context "when YOSYS_PATH is valid and returns a successful response" do
      let(:response_body) { instance_double(HTTP::Response::Body, to_s: yosys_response.to_json) }
      let(:response_double) { instance_double(HTTP::Response, code: 200, body: response_body) }

      before do
        allow(ENV).to receive(:fetch).with("YOSYS_PATH", "http://127.0.0.1:3040").and_return("http://127.0.0.1:3040")
        allow(HTTP).to receive_messages(timeout: HTTP, post: response_double)
      end

      it "returns a successful response with correct JSON" do
        post "/api/v1/simulator/verilogcv", params: { code: code }
        expect(response.status).to eq(200)
        expect(response.parsed_body).to eq(yosys_response.with_indifferent_access)
      end
    end

    context "when YOSYS_PATH is valid but returns a failed response" do
      let(:response_body) { instance_double(HTTP::Response::Body, to_s: "") }
      let(:response_double) { instance_double(HTTP::Response, code: 500, body: response_body) }

      before do
        allow(ENV).to receive(:fetch).with("YOSYS_PATH", "http://127.0.0.1:3040").and_return("http://127.0.0.1:3040")
        allow(HTTP).to receive_messages(timeout: HTTP, post: response_double)
      end

      it "returns the failed status code" do
        post "/api/v1/simulator/verilogcv", params: { code: code }
        expect(response.status).to eq(500)
      end
    end

    context "when Yosys service is not running" do
      before do
        allow(ENV).to receive(:fetch).with("YOSYS_PATH", "http://127.0.0.1:3040").and_return("http://127.0.0.1:3040")
        allow(HTTP).to receive(:timeout).and_return(HTTP)
        allow(HTTP).to receive(:post).and_raise(HTTP::ConnectionError.new("failed to connect: Connection refused"))
      end

      it "returns 503 service unavailable with error message" do
        post "/api/v1/simulator/verilogcv", params: { code: code }
        expect(response.status).to eq(503)
        expect(response.parsed_body["error"]).to eq("Verilog service unavailable")
        expect(response.parsed_body["message"]).to include("yosys2digitaljs-server")
      end
    end

    context "when Yosys service times out" do
      before do
        allow(ENV).to receive(:fetch).with("YOSYS_PATH", "http://127.0.0.1:3040").and_return("http://127.0.0.1:3040")
        allow(HTTP).to receive(:timeout).and_return(HTTP)
        allow(HTTP).to receive(:post).and_raise(HTTP::TimeoutError.new("Timed out"))
      end

      it "returns 503 service unavailable with error message" do
        post "/api/v1/simulator/verilogcv", params: { code: code }
        expect(response.status).to eq(503)
        expect(response.parsed_body["error"]).to eq("Verilog service unavailable")
      end
    end

    context "when code parameter is missing" do
      it "returns 400 bad request" do
        post "/api/v1/simulator/verilogcv", params: { code: "" }
        expect(response.status).to eq(400)
        expect(response.parsed_body["error"]).to eq("code is required")
      end
    end
  end
end
