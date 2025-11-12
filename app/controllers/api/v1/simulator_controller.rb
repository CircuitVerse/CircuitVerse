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
    return render json: { error: "code is required" }, status: :bad_request if params[:code].blank?

    url = "#{ENV.fetch('YOSYS_PATH', 'http://127.0.0.1:3040')}/getJSON"
    http = HTTP.timeout(connect: 2, write: 2, read: 5)
    yosys_response = http.post(url, json: { code: params[:code] })
    render body: yosys_response.body.to_s, content_type: "application/json", status: yosys_response.code
  rescue HTTP::ConnectionError, HTTP::TimeoutError, Errno::ECONNREFUSED, SocketError => e
    Rails.logger.warn("verilog_cv upstream error: #{e.class}: #{e.message}")
    response.headers["Retry-After"] = "10"
    error_message = {
      error: "Verilog service unavailable",
      message: "The Verilog synthesis service is not running. Please ensure yosys2digitaljs-server is started.",
      details: e.message
    }
    render json: error_message, status: :service_unavailable
  end
end
