# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Api::V1::SimulatorController < Api::V1::BaseController
  def post_issue
    unless params[:text] && params[:circuit_data]
      render json: { error: 'Missing required parameters' }, status: :unprocessable_entity and return
    end
  
    issue_circuit_data = IssueCircuitDatum.new(data: params[:circuit_data])
  
    unless issue_circuit_data.save
      render json: { error: issue_circuit_data.errors.full_messages.to_sentence }, status: :unprocessable_entity and return
    end
  
    circuit_data_url = "#{request.base_url}/simulator/issue_circuit_data/#{issue_circuit_data.id}"
    text = "#{params[:text]}\nCircuit Data: #{circuit_data_url}"
  
    if post_to_slack(text)
      render json: { success: true, message: 'Issue submitted successfully' }, status: :ok
    else
      render json: { error: 'Failed to submit issue to Slack' }, status: :unprocessable_entity
    end
  end
  
  private
  
  def post_to_slack(message)
    url = ENV.fetch("SLACK_ISSUE_HOOK_URL", nil)
    response = HTTP.post(url, json: { text: message })
    response.code == 200
  end  
end
