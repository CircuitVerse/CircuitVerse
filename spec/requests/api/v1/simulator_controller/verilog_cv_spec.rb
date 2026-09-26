# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SimulatorController, type: :request do
  describe "POST /api/v1/simulator/verilogcv" do
    let(:code) { "module top(input a, output y); assign y = a; endmodule" }

    context "when compilation succeeds" do
      before do
        allow(Yosys2Digitaljs::Runner).to receive(:compile).with(code).and_return({ "devices" => {} })
      end

      it "returns a successful response with compiled JSON" do
        post "/api/v1/simulator/verilogcv", params: { code: code }
        expect(response.status).to eq(200)
        expect(response.parsed_body).to eq({ "devices" => {} }.with_indifferent_access)
      end
    end

    context "when code is too large" do
      it "returns 413" do
        post "/api/v1/simulator/verilogcv", params: { code: "a" * (Api::V1::SimulatorController::MAX_CODE_SIZE + 1) }
        expect(response.status).to eq(413)
      end
    end

    context "when compilation raises a syntax error" do
      before do
        allow(Yosys2Digitaljs::Runner).to receive(:compile).and_raise(Yosys2Digitaljs::SyntaxError, "bad syntax")
      end

      it "returns 422" do
        post "/api/v1/simulator/verilogcv", params: { code: code }
        expect(response.status).to eq(422)
      end
    end
  end
end
