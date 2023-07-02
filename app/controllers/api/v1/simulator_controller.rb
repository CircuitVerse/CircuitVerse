# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Api::V1::SimulatorController < Api::V1::BaseController
  def post_issue
    check_required_params
    issue_circuit_data = create_issue_circuit_data

    circuit_data_url = "#{request.base_url}/simulator/issue_circuit_data/#{issue_circuit_data.id}"
    text = "#{params[:text]}\nCircuit Data: #{circuit_data_url}"

    url = ENV.fetch("SLACK_ISSUE_HOOK_URL", nil)
    response = HTTP.post(url, json: { text: text })
    unless response.code == 200
      render json: { error: 'Failed to submit issue to Slack' }, status: :unprocessable_entity and return
    end

    render json: { success: true, message: 'Issue submitted successfully' }, status: :ok
  end

  private

    def check_required_params
      unless params[:text] && params[:circuit_data]
        render json: { error: 'Missing required parameters' }, status: :unprocessable_entity and return
      end
    end

    def create_issue_circuit_data
      issue_circuit_data = IssueCircuitDatum.new(data: params[:circuit_data])
      unless issue_circuit_data.save
        error_message = issue_circuit_data.errors.full_messages.to_sentence
        render(json: { error: error_message }, status: :unprocessable_entity) and return
      end
      issue_circuit_data
    end    
end
