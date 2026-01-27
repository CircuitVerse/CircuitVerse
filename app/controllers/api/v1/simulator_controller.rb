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
             status: :unprocessable_content and return
    end

    response = HTTP.post(url, json: { text: text })
    unless response.code == 200
      render json: { error: "Failed to submit issue to Slack" },
             status: :unprocessable_content and return
    end

    render json: { success: true, message: "Issue submitted successfully" }, status: :ok
  end
  # rubocop:enable Metrics/MethodLength

  # POST /api/v1/simulator/verilogcv
  def verilog_cv
    result = Yosys2Digitaljs::Runner.compile(params[:code])
    render json: result
  rescue Yosys2Digitaljs::Runner::TimeoutError => e
    render json: { message: e.message }, status: :service_unavailable
  rescue Yosys2Digitaljs::Converter::Error => e
    render json: { message: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { message: "Compilation failed: #{e.message}" }, status: :internal_server_error
  end
end
