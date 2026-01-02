# frozen_string_literal: true

class Api::V1::SimulatorController < Api::V1::BaseController
  # POST /api/v1/simulator/post_issue
  # rubocop:disable Metrics/MethodLength
  def post_issue
    issue_circuit_data = IssueCircuitDatum.create(data: params[:circuit_data])

    circuit_data_url = "#{request.base_url}/simulator/issue_circuit_data/#{issue_circuit_data.id}"
    text = "#{params[:text]}\nCircuit Data: #{circuit_data_url}"

    url = ENV.fetch("SLACK_ISSUE_HOOK_URL", nil)

    if url.nil? || !url.start_with?(
      "http://", "https://"
    )
      render json: { error: "Invalid or missing Slack webhook URL" },
             status: :unprocessable_entity and return
    end

    response = HTTP.post(url, json: { text: text })
    unless response.code == 200
      render json: { error: "Failed to submit issue to Slack" },
             status: :unprocessable_entity and return
    end

    render json: { success: true, message: "Issue submitted successfully" }, status: :ok
  end
  # rubocop:enable Metrics/MethodLength

  # POST /api/v1/simulator/verilogcv
  def verilog_cv
    url = "#{ENV.fetch('YOSYS_PATH', 'http://127.0.0.1:3040')}/getJSON"
    begin
      response = HTTP.timeout(30).post(url, json: { code: params[:code] })
      render json: response.body.to_s, status: response.code
    rescue HTTP::TimeoutError, HTTP::ConnectionError => e
      Rails.logger.error "Verilog synthesis service error: #{e.message}"
      api_error(status: 503, errors: "Verilog synthesis service is currently unavailable. Please try again later.")
    rescue StandardError => e
      Rails.logger.error "Unexpected error in verilog_cv: #{e.class} - #{e.message}"
      api_error(status: 500, errors: "An error occurred while processing your Verilog code. Please try again later.")
    end
  end
end
