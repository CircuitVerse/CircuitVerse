# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::FsmSynthesizer', type: :request do
  describe 'POST /api/v1/fsm_synthesize' do
    context 'with valid Moore FSM JSON' do
      let(:moore_json) do
        {
          machine_type: 'moore',
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S0' },
            { from: 'S0', input: '1', to: 'S1' },
            { from: 'S1', input: '0', to: 'S1' },
            { from: 'S1', input: '1', to: 'S0' }
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z' }
        }.to_json
      end

      let(:request_body) do
        {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'binary'
        }
      end

      it 'synthesizes and returns circuit structure' do
        post '/api/v1/fsm_synthesize', params: request_body, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['machine_type']).to eq('moore')
        expect(json['states'].size).to eq(2)
        expect(json['state_encoding']).to be_present
        expect(json['next_state_equations']).to be_present
        expect(json['output_equations']).to be_present
        expect(json['circuit']).to be_present
      end

      it 'includes state encoding in response' do
        post '/api/v1/fsm_synthesize', params: request_body, as: :json

        json = response.parsed_body
        expect(json['state_encoding']).to have_key('S0')
        expect(json['state_encoding']['S0']).to be_an(Array)
      end

      it 'includes Boolean equations in response' do
        post '/api/v1/fsm_synthesize', params: request_body, as: :json

        json = response.parsed_body
        expect(json['next_state_equations']).to be_a(Hash)
        expect(json['output_equations']).to be_a(Hash)
      end

      it 'returns circuit metadata' do
        post '/api/v1/fsm_synthesize', params: request_body, as: :json

        json = response.parsed_body
        circuit = json['circuit']
        expect(circuit['version']).to eq(1)
        expect(circuit['metadata']).to have_key('machine_type')
        expect(circuit['components']).to be_present
      end
    end

    context 'with valid Mealy FSM JSON' do
      let(:mealy_json) do
        {
          machine_type: 'mealy',
          inputs: ['0', '1'],
          outputs: ['w'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S0', output: 'w' },
            { from: 'S0', input: '1', to: 'S1', output: 'w' },
            { from: 'S1', input: '0', to: 'S1', output: 'w' },
            { from: 'S1', input: '1', to: 'S0', output: 'w' }
          ]
        }.to_json
      end

      let(:request_body) do
        {
          fsm_data: mealy_json,
          format: 'json'
        }
      end

      it 'synthesizes Mealy machine' do
        post '/api/v1/fsm_synthesize', params: request_body, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['machine_type']).to eq('mealy')
      end
    end

    context 'with CSV format' do
      let(:csv_data) do
        <<~CSV
          machine_type: moore
          inputs: 0,1
          outputs: z
          states: S0(initial),S1
          state_outputs:
          S0,z
          S1,z
          transitions:
          from,input,to,output
          S0,0,S0,
          S0,1,S1,
          S1,0,S1,
          S1,1,S0,
        CSV
      end

      let(:request_body) do
        {
          fsm_data: csv_data,
          format: 'csv'
        }
      end

      it 'parses CSV input and synthesizes' do
        post '/api/v1/fsm_synthesize', params: request_body, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['machine_type']).to eq('moore')
      end
    end

    context 'with one_hot encoding' do
      let(:fsm_json) do
        {
          machine_type: 'moore',
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }, { id: 'S2' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S0' },
            { from: 'S0', input: '1', to: 'S1' },
            { from: 'S1', input: '0', to: 'S2' },
            { from: 'S1', input: '1', to: 'S0' },
            { from: 'S2', input: '0', to: 'S1' },
            { from: 'S2', input: '1', to: 'S0' }
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z', 'S2' => 'z' }
        }.to_json
      end

      let(:request_body) do
        {
          fsm_data: fsm_json,
          format: 'json',
          encoding: 'one_hot'
        }
      end

      it 'uses one_hot encoding when specified' do
        post '/api/v1/fsm_synthesize', params: request_body, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        # One-hot: 3 states = 3 bits, each state has exactly one 1
        expect(json['state_encoding']['S0']).to eq([1, 0, 0])
        expect(json['state_encoding']['S1']).to eq([0, 1, 0])
        expect(json['state_encoding']['S2']).to eq([0, 0, 1])
      end
    end

    context 'with missing required parameters' do
      it 'returns 400 when fsm_data is missing' do
        post '/api/v1/fsm_synthesize', params: { format: 'json' }, as: :json

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns 422 when format is missing' do
        post '/api/v1/fsm_synthesize', params: { fsm_data: '{}' }, as: :json

        expect(response).to have_http_status(422)
      end

      it 'returns 422 when format is invalid' do
        post '/api/v1/fsm_synthesize', params: { fsm_data: '{}', format: 'xml' }, as: :json

        expect(response).to have_http_status(422)
      end
    end

    context 'with invalid FSM structure' do
      let(:invalid_fsm) do
        {
          machine_type: 'moore',
          inputs: [],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }],
          transitions: [],
          state_outputs: { 'S0' => 'z' }
        }.to_json
      end

      it 'returns 422 with validation error' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: invalid_fsm,
          format: 'json'
        }, as: :json

        expect(response).to have_http_status(422)
        expect(response.parsed_body).to have_key('errors')
      end
    end

    context 'with non-deterministic FSM' do
      let(:non_deterministic_fsm) do
        {
          machine_type: 'moore',
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }, { id: 'S2' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S0' },
            { from: 'S0', input: '0', to: 'S1' },  # Duplicate input - non-deterministic!
            { from: 'S0', input: '1', to: 'S2' },
            { from: 'S1', input: '0', to: 'S0' },
            { from: 'S1', input: '1', to: 'S1' },
            { from: 'S2', input: '0', to: 'S2' },
            { from: 'S2', input: '1', to: 'S0' }
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z', 'S2' => 'z' }
        }.to_json
      end

      it 'rejects non-deterministic FSM' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: non_deterministic_fsm,
          format: 'json'
        }, as: :json

        expect(response).to have_http_status(422)
        expect(response.parsed_body['errors']).to include('conflict' || 'duplicate')
      end
    end

    context 'with incomplete transitions' do
      let(:incomplete_fsm) do
        {
          machine_type: 'moore',
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }],
          transitions: [
            { from: 'S0', input: '0', to: 'S1' }
            # Missing S0 on input 1, S1 on input 0, S1 on input 1
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z' }
        }.to_json
      end

      it 'rejects incomplete FSM' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: incomplete_fsm,
          format: 'json'
        }, as: :json

        expect(response).to have_http_status(422)
        expect(response.parsed_body['errors']).to include('complete' || 'missing')
      end
    end

    context 'with malformed JSON' do
      it 'returns 400 for invalid JSON' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: '{ invalid json }',
          format: 'json'
        }, as: :json

        expect(response).to have_http_status(400)
      end
    end
  end
end
