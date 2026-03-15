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

  MAX_CODE_SIZE = 10_000 # 10KB limit

  # POST /api/v1/simulator/verilogcv
  def verilog_cv
    if params[:code].to_s.bytesize > MAX_CODE_SIZE
      render json: { message: "Code too large (max #{MAX_CODE_SIZE} bytes)" }, status: :payload_too_large
      return
    end

    if Flipper.enabled?(:yosys_local_gem, current_user)
      compile_with_local_gem
    else
      compile_with_external_api
    end
  end

  private

    # HTTP client with reasonable timeouts to prevent hanging
    def http_client
      HTTP.timeout(connect: 5, write: 10, read: 30)
    end

    def compile_with_local_gem
      code = params[:code].to_s
      result = Yosys2Digitaljs::Runner.compile(code)
      render json: result
    rescue Yosys2Digitaljs::SyntaxError => e
      render json: { message: "Syntax Error: #{e.message}" }, status: :unprocessable_entity
    rescue Yosys2Digitaljs::Runner::TimeoutError => e
      render json: { message: e.message }, status: :service_unavailable
    rescue Yosys2Digitaljs::Error => e
      render json: { message: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error("[Yosys Compilation Error] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
      render json: { message: "Compilation failed" }, status: :internal_server_error
    end

    def compile_with_external_api
      yosys_url = "#{ENV.fetch('YOSYS_PATH', 'http://127.0.0.1:3040')}/getJSON"
      response = http_client.post(yosys_url, json: { code: params[:code].to_s })
      render json: JSON.parse(response.to_s), status: response.code
    rescue HTTP::TimeoutError
      render json: { message: "Yosys service timed out" }, status: :gateway_timeout
    rescue HTTP::Error => e
      Rails.logger.error("[Yosys External API Error] #{e.class}: #{e.message}")
      render json: { message: "External API unavailable" }, status: :service_unavailable
    rescue JSON::ParserError
      render json: { message: "Invalid response from Yosys API" }, status: :internal_server_error
    end
end
