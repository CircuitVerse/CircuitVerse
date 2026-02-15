# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SimulatorController, type: :request do
  describe "POST /api/v1/simulator/verilogcv" do
    let(:code) { "sample_code" }
    let(:yosys_url) { "#{ENV.fetch('YOSYS_PATH', 'http://127.0.0.1:3040')}/getJSON" }
    let(:yosys_response) { { "data" => "response_from_yosys" } }

    context "when YOSYS_PATH is valid and returns a successful response" do
      let(:response_double) { instance_double(HTTP::Response, code: 200, to_s: yosys_response.to_json) }

      before do
        http_double = double
        allow(ENV).to receive(:fetch).with("YOSYS_PATH", "http://127.0.0.1:3040").and_return("http://127.0.0.1:3040")
        allow(HTTP).to receive(:timeout).with(10).and_return(http_double)
        allow(http_double).to receive(:post).with(yosys_url, json: { code: code }).and_return(response_double)
      end

      it "returns a successful response with correct JSON" do
        post "/api/v1/simulator/verilogcv", params: { code: code }
        expect(response.status).to eq(200)
        expect(response.parsed_body).to eq(yosys_response.with_indifferent_access)
      end
    end

    context "when YOSYS_PATH is valid but returns a failed response" do
      let(:response_double) { instance_double(HTTP::Response, code: 500, to_s: "") }

      before do
        http_double = double
        allow(ENV).to receive(:fetch).with("YOSYS_PATH", "http://127.0.0.1:3040").and_return("http://127.0.0.1:3040")
        allow(HTTP).to receive(:timeout).with(10).and_return(http_double)
        allow(http_double).to receive(:post).with(yosys_url, json: { code: code }).and_return(response_double)
      end

      it "returns the failed status code" do
        post "/api/v1/simulator/verilogcv", params: { code: code }
        expect(response.status).to eq(500)
      end
    end

    context "when Yosys service is unavailable" do
      before do
        http_double = double
        allow(ENV).to receive(:fetch).with("YOSYS_PATH", "http://127.0.0.1:3040").and_return("http://127.0.0.1:3040")
        allow(HTTP).to receive(:timeout).with(10).and_return(http_double)
        allow(http_double).to receive(:post).with(yosys_url, json: { code: code }).and_raise(Errno::ECONNREFUSED)
      end

      it "returns service unavailable status with error message" do
        post "/api/v1/simulator/verilogcv", params: { code: code }
        expect(response.status).to eq(503)
        expect(response.parsed_body["error"]).to be_present
      end
    end
  end
end
