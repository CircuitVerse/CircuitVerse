# frozen_string_literal: true

class Api::V1::SimulatorController < Api::V1::BaseController
  skip_after_action :verify_authorized

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
      return render json: { error: "Invalid or missing Slack webhook URL" },
                    status: :unprocessable_content
    end

    response = HTTP.post(url, json: { text: text })
    unless response.code == 200
      return render json: { error: "Failed to submit issue to Slack" },
                    status: :unprocessable_content
    end

    render json: { success: true, message: "Issue submitted successfully" }, status: :ok
  end
  # rubocop:enable Metrics/MethodLength

  MAX_CODE_SIZE = 10_000 # 10KB limit

  # POST /api/v1/simulator/verilogcv
  def verilog_cv
    if params[:code].to_s.bytesize > MAX_CODE_SIZE
      render json: { message: "Code too large (max #{MAX_CODE_SIZE} bytes)" }, status: :content_too_large
      return
    end

    compile_with_local_gem
  end

  private

    def compile_with_local_gem
      code = params[:code].to_s
      result = Yosys2Digitaljs::Runner.compile(code)
      render json: result
    rescue Yosys2Digitaljs::SyntaxError => e
      render json: { message: "Syntax Error: #{e.message}" }, status: :unprocessable_content
    rescue Yosys2Digitaljs::Runner::TimeoutError => e
      render json: { message: e.message }, status: :service_unavailable
    rescue Yosys2Digitaljs::Error => e
      render json: { message: e.message }, status: :unprocessable_content
    rescue StandardError => e
      Rails.logger.error("[Yosys Compilation Error] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
      render json: { message: "Compilation failed" }, status: :internal_server_error
    end
end
