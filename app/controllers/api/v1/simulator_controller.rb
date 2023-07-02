# frozen_string_literal: true

class Api::V1::SimulatorController < Api::V1::BaseController
  def post_issue
    issue_circuit_data = IssueCircuitDatum.new(data: params[:circuit_data]).tap(&:save)

    circuit_data_url = "#{request.base_url}/simulator/issue_circuit_data/#{issue_circuit_data.id}"
    text = "#{params[:text]}\nCircuit Data: #{circuit_data_url}"

    url = ENV.fetch("SLACK_ISSUE_HOOK_URL", nil)

    if url.nil? || !url.start_with?("http://", "https://")
      render json: { error: "Invalid or missing Slack webhook URL" }, status: :internal_server_error and return
    end

    response = HTTP.post(url, json: { text: text })
    unless response.code == 200
      render json: { error: "Failed to submit issue to Slack" }, status: :internal_server_error and return
    end

    render json: { success: true, message: "Issue submitted successfully" }, status: :ok
  end
end
