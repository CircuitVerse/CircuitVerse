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

    context 'with D flip-flop (default)' do
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

      it 'synthesizes with D flip-flops by default' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['flip_flop_type']).to eq('d')
        expect(json['excitation_equations']).to have_key('D0')
      end

      it 'synthesizes with explicit D flip-flop selection' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          flip_flop_type: 'd'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['flip_flop_type']).to eq('d')
        expect(json['excitation_equations']).to be_a(Hash)
        expect(json['excitation_equations']).to have_key('D0')
      end
    end

    context 'with JK flip-flop' do
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

      it 'synthesizes with JK flip-flops' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          flip_flop_type: 'jk'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['flip_flop_type']).to eq('jk')
        expect(json['excitation_equations']).to have_key('J0')
        expect(json['excitation_equations']).to have_key('K0')
      end

      it 'generates correct number of JK equations' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          flip_flop_type: 'jk'
        }, as: :json

        json = response.parsed_body
        # 2 bits for 2 states, so 4 equations (J0, K0, J1, K1)
        expect(json['excitation_equations'].size).to eq(4)
      end

      it 'includes output equations alongside JK excitation' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          flip_flop_type: 'jk'
        }, as: :json

        json = response.parsed_body
        expect(json['output_equations']).to be_present
        expect(json['output_equations']).to have_key('z')
      end
    end

    context 'with SR flip-flop' do
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

      it 'synthesizes with SR flip-flops' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          flip_flop_type: 'sr'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['flip_flop_type']).to eq('sr')
        expect(json['excitation_equations']).to have_key('S0')
        expect(json['excitation_equations']).to have_key('R0')
      end

      it 'generates correct number of SR equations' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          flip_flop_type: 'sr'
        }, as: :json

        json = response.parsed_body
        # 2 bits for 2 states, so 4 equations (S0, R0, S1, R1)
        expect(json['excitation_equations'].size).to eq(4)
      end
    end

    context 'with invalid flip-flop type' do
      let(:fsm_json) do
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

      it 'returns 422 for invalid flip-flop type' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: fsm_json,
          format: 'json',
          flip_flop_type: 'invalid'
        }, as: :json

        expect(response).to have_http_status(422)
        expect(response.parsed_body['errors']).to include('flip-flop')
      end
    end

    context 'flip-flop type with 3-state FSM' do
      let(:three_state_fsm) do
        {
          machine_type: 'moore',
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [
            { id: 'S0', initial: true },
            { id: 'S1' },
            { id: 'S2' }
          ],
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

      it 'generates D equations with 2 bits for 3 states' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: three_state_fsm,
          format: 'json',
          flip_flop_type: 'd'
        }, as: :json

        json = response.parsed_body
        expect(json['excitation_equations'].size).to eq(2) # 2 bits
        expect(json['excitation_equations']).to have_key('D0')
        expect(json['excitation_equations']).to have_key('D1')
      end

      it 'generates JK equations with 2 bits for 3 states' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: three_state_fsm,
          format: 'json',
          flip_flop_type: 'jk'
        }, as: :json

        json = response.parsed_body
        expect(json['excitation_equations'].size).to eq(4) # J0, K0, J1, K1
      end

      it 'generates SR equations with 2 bits for 3 states' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: three_state_fsm,
          format: 'json',
          flip_flop_type: 'sr'
        }, as: :json

        json = response.parsed_body
        expect(json['excitation_equations'].size).to eq(4) # S0, R0, S1, R1
      end
    end

    context 'with gray code encoding' do
      let(:moore_json) do
        {
          machine_type: 'moore',
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [
            { id: 'S0', initial: true },
            { id: 'S1' },
            { id: 'S2' },
            { id: 'S3' }
          ],
          transitions: [
            { from: 'S0', input: '0', to: 'S0' },
            { from: 'S0', input: '1', to: 'S1' },
            { from: 'S1', input: '0', to: 'S2' },
            { from: 'S1', input: '1', to: 'S3' },
            { from: 'S2', input: '0', to: 'S0' },
            { from: 'S2', input: '1', to: 'S3' },
            { from: 'S3', input: '0', to: 'S2' },
            { from: 'S3', input: '1', to: 'S0' }
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z', 'S2' => 'z', 'S3' => 'z' }
        }.to_json
      end

      it 'synthesizes with gray code encoding' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'gray'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['state_encoding']).to be_present
        expect(json['state_encoding']['S0']).to eq([0, 0])
        expect(json['state_encoding']['S1']).to eq([0, 1])
        expect(json['state_encoding']['S2']).to eq([1, 1])
        expect(json['state_encoding']['S3']).to eq([1, 0])
      end

      it 'returns 2 bits for 4 states with gray encoding' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'gray'
        }, as: :json

        json = response.parsed_body
        expect(json['state_encoding']['S0'].size).to eq(2)
        expect(json['state_encoding']['S3'].size).to eq(2)
      end

      it 'generates correct equations with gray encoding' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'gray'
        }, as: :json

        json = response.parsed_body
        expect(json['excitation_equations']).to be_present
        # Gray encoding should produce valid Boolean expressions
        json['excitation_equations'].each do |_eq_id, expr|
          expect(expr).to be_a(String)
          expect(expr).not_to be_empty
        end
      end
    end

    context 'with invalid encoding type' do
      let(:fsm_json) do
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

      it 'returns 422 for invalid encoding type' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: fsm_json,
          format: 'json',
          encoding: 'invalid'
        }, as: :json

        expect(response).to have_http_status(422)
        expect(response.parsed_body['errors']).to include('encoding')
      end
    end

    context 'gray encoding with different state counts' do
      it 'encodes 2 states with 1 bit' do
        two_state_fsm = {
          machine_type: 'moore',
          inputs: ['x'],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }],
          transitions: [
            { from: 'S0', input: 'x', to: 'S1' },
            { from: 'S1', input: 'x', to: 'S0' }
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z' }
        }.to_json

        post '/api/v1/fsm_synthesize', params: {
          fsm_data: two_state_fsm,
          format: 'json',
          encoding: 'gray'
        }, as: :json

        json = response.parsed_body
        expect(json['state_encoding']['S0']).to eq([0])
        expect(json['state_encoding']['S1']).to eq([1])
      end

      it 'encodes 8 states with 3 bits' do
        eight_state_fsm = {
          machine_type: 'moore',
          inputs: ['x'],
          outputs: ['z'],
          states: Array.new(8) { |i| { id: "S#{i}", initial: i == 0 } },
          transitions: (0...7).map { |i| { from: "S#{i}", input: 'x', to: "S#{i + 1}" } }
                            .append({ from: 'S7', input: 'x', to: 'S0' }),
          state_outputs: Hash[Array.new(8) { |i| ["S#{i}", 'z'] }]
        }.to_json

        post '/api/v1/fsm_synthesize', params: {
          fsm_data: eight_state_fsm,
          format: 'json',
          encoding: 'gray'
        }, as: :json

        json = response.parsed_body
        # Verify all 8 states are encoded
        expect(json['state_encoding'].size).to eq(8)
        # Verify each state has 3 bits
        json['state_encoding'].each do |_state, bits|
          expect(bits.size).to eq(3)
        end
      end
    end

    context 'gray vs binary encoding comparison' do
      let(:moore_json) do
        {
          machine_type: 'moore',
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [
            { id: 'S0', initial: true },
            { id: 'S1' },
            { id: 'S2' },
            { id: 'S3' }
          ],
          transitions: [
            { from: 'S0', input: '0', to: 'S0' },
            { from: 'S0', input: '1', to: 'S1' },
            { from: 'S1', input: '0', to: 'S2' },
            { from: 'S1', input: '1', to: 'S3' },
            { from: 'S2', input: '0', to: 'S0' },
            { from: 'S2', input: '1', to: 'S3' },
            { from: 'S3', input: '0', to: 'S2' },
            { from: 'S3', input: '1', to: 'S0' }
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z', 'S2' => 'z', 'S3' => 'z' }
        }.to_json
      end

      it 'both binary and gray encodings produce valid synthesis results' do
        # Test binary
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'binary'
        }, as: :json
        expect(response).to have_http_status(:ok)

        # Test gray
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'gray'
        }, as: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with reset configuration' do
      let(:moore_json) do
        {
          machine_type: 'moore',
          inputs: ['0', '1'],
          outputs: ['z'],
          states: [
            { id: 'S0', initial: true },
            { id: 'S1' },
            { id: 'S2' }
          ],
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

      it 'synthesizes with no reset by default' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json).not_to have_key('reset_config')
      end

      it 'synthesizes with synchronous reset' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          reset_type: 'synchronous'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json).to have_key('reset_config')
        expect(json['reset_config']['reset_type']).to eq('synchronous')
        expect(json['reset_config']['reset_state']).to eq('S0')
      end

      it 'synthesizes with asynchronous reset' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          reset_type: 'asynchronous'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json).to have_key('reset_config')
        expect(json['reset_config']['reset_type']).to eq('asynchronous')
      end

      it 'resets to initial state by default' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          reset_type: 'synchronous'
        }, as: :json

        json = response.parsed_body
        expect(json['reset_config']['reset_state']).to eq('S0')
      end

      it 'resets to specified state' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          reset_type: 'asynchronous',
          reset_state: 'S1'
        }, as: :json

        json = response.parsed_body
        expect(json['reset_config']['reset_state']).to eq('S1')
      end

      it 'includes reset circuit information' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          reset_type: 'synchronous'
        }, as: :json

        json = response.parsed_body
        expect(json['circuit']).to have_key('reset')
        expect(json['circuit']['reset']).to have_key('reset_type')
        expect(json['circuit']['reset']).to have_key('reset_state')
        expect(json['circuit']['reset']).to have_key('reset_input')
      end

      it 'returns 422 for invalid reset type' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          reset_type: 'invalid'
        }, as: :json

        expect(response).to have_http_status(422)
        expect(response.parsed_body['errors']).to include('reset')
      end

      it 'returns 422 for non-existent reset state' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          reset_type: 'synchronous',
          reset_state: 'S99'
        }, as: :json

        expect(response).to have_http_status(422)
      end

      it 'works with both reset and flip-flop type parameters' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          reset_type: 'asynchronous',
          flip_flop_type: 'jk'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['reset_config']).to be_present
        expect(json['flip_flop_type']).to eq('jk')
      end

      it 'works with reset and encoding parameters' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          reset_type: 'synchronous',
          encoding: 'gray'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['reset_config']).to be_present
        expect(json['state_encoding']).to be_present
      end
    end

    context 'with async input synchronization' do
      let(:moore_json) do
        {
          machine_type: 'moore',
          inputs: ['X', 'external_input'],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }, { id: 'S1' }, { id: 'S2' }],
          transitions: [
            { from: 'S0', input: 'X', to: 'S1' },
            { from: 'S1', input: 'external_input', to: 'S2' },
            { from: 'S2', input: 'X', to: 'S0' }
          ],
          state_outputs: { 'S0' => 'z', 'S1' => 'z', 'S2' => 'z' }
        }.to_json
      end

      it 'configures single input synchronizer with two_flop type' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'binary',
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              sync_type: 'two_flop',
              num_stages: 2
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['synchronizers']).to be_present
        expect(json['synchronizers']).to have_key('external_input')
        expect(json['metastability_analysis']).to be_present
      end

      it 'includes synchronizer circuit specifications' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              sync_type: 'two_flop'
            }
          ]
        }, as: :json

        json = response.parsed_body
        sync_circuit = json['synchronizers']['external_input']
        
        expect(sync_circuit[:type]).to eq('two_flop_synchronizer')
        expect(sync_circuit[:description]).to be_present
        expect(sync_circuit[:components]).to be_present
        expect(sync_circuit[:timing]).to be_present
      end

      it 'configures gray_code synchronizer for multi-bit signals' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              sync_type: 'gray',
              num_stages: 3
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        sync_circuit = json['synchronizers']['external_input']
        
        expect(sync_circuit[:type]).to eq('gray_code_synchronizer')
        expect(sync_circuit[:components].length).to eq(3)
      end

      it 'configures pulse synchronizer for strobe signals' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              sync_type: 'pulse'
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        sync_circuit = json['synchronizers']['external_input']
        
        expect(sync_circuit[:type]).to eq('pulse_synchronizer')
      end

      it 'configures handshake (async FIFO) synchronizer' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              sync_type: 'handshake',
              num_stages: 2
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        sync_circuit = json['synchronizers']['external_input']
        
        expect(sync_circuit[:type]).to eq('handshake_fifo')
      end

      it 'synchronizes multiple inputs' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'X',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              sync_type: 'two_flop'
            },
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              sync_type: 'gray'
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['synchronizers']).to have_key('X')
        expect(json['synchronizers']).to have_key('external_input')
        expect(json['synchronizers']['X'][:type]).to eq('two_flop_synchronizer')
        expect(json['synchronizers']['external_input'][:type]).to eq('gray_code_synchronizer')
      end

      it 'provides metastability analysis' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys'
            }
          ]
        }, as: :json

        json = response.parsed_body
        analysis = json['metastability_analysis']
        
        expect(analysis).to be_present
        expect(analysis[:overall_risk]).to be_present
        expect(analysis[:synchronized_inputs]).to be_present
        expect(analysis[:unsynchronized_inputs]).to be_present
      end

      it 'identifies unsynchronized inputs in analysis' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys'
            }
          ]
        }, as: :json

        json = response.parsed_body
        analysis = json['metastability_analysis']
        
        # X is not synchronized, so should appear in unsynchronized_inputs
        expect(analysis[:unsynchronized_inputs]).to include('X')
      end

      it 'supports custom clock frequencies' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              freq_src_mhz: 200,
              freq_dest_mhz: 100
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'works with async inputs and reset together' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          reset_type: 'asynchronous',
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys'
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['reset_config']).to be_present
        expect(json['synchronizers']).to be_present
      end

      it 'works with async inputs, reset, and encoding' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'gray',
          flip_flop_type: 'jk',
          reset_type: 'synchronous',
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              sync_type: 'gray'
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['flip_flop_type']).to eq('jk')
        expect(json['reset_config']).to be_present
        expect(json['synchronizers']).to be_present
      end
    end

    context 'with invalid async input configuration' do
      let(:moore_json) do
        {
          machine_type: 'moore',
          inputs: ['X'],
          outputs: ['z'],
          states: [{ id: 'S0', initial: true }],
          transitions: [],
          state_outputs: { 'S0' => 'z' }
        }.to_json
      end

      it 'rejects missing input_name in sync_inputs' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              src_clock: 'clk_src',
              dest_clock: 'clk_sys'
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = response.parsed_body
        expect(json['errors']).to include('required')
      end

      it 'rejects missing src_clock in sync_inputs' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'X',
              dest_clock: 'clk_sys'
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'rejects invalid sync_type' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'X',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              sync_type: 'invalid_type'
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = response.parsed_body
        expect(json['errors']).to include('invalid sync_type')
      end

      it 'rejects invalid num_stages' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          sync_inputs: [
            {
              input_name: 'X',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys',
              num_stages: 1
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = response.parsed_body
        expect(json['errors']).to include('num_stages')
      end
    end

    context 'with state diagram generation' do
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

      it 'generates diagram with hierarchy layout by default' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'binary'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['diagram']).to be_present
        expect(json['diagram']['states']).to be_present
        expect(json['diagram']['transitions']).to be_present
        expect(json['diagram']['metadata']).to be_present
      end

      it 'generates diagram with circular layout' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          diagram_layout: 'circle'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        diagram = json['diagram']
        expect(diagram['metadata']['layout']).to eq('circle')
        expect(diagram['states'].all? { |s| s.key?('x') && s.key?('y') }).to be true
      end

      it 'generates diagram with grid layout' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          diagram_layout: 'grid'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['diagram']['metadata']['layout']).to eq('grid')
      end

      it 'skips diagram generation when include_diagram is false' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          include_diagram: false
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['diagram']).to be_nil
      end

      it 'includes diagram metadata' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json'
        }, as: :json

        json = response.parsed_body
        metadata = json['diagram']['metadata']
        expect(metadata['deterministic']).to be_in([true, false])
        expect(metadata['complete']).to be_in([true, false])
        expect(metadata['state_count']).to eq(2)
        expect(metadata['transition_count']).to be >= 4
      end
    end

    context 'with equation optimization' do
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

      it 'skips optimization when optimization_level is none' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          optimization_level: 'none'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['optimization_report']).to be_nil
      end

      it 'optimizes with basic level' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          optimization_level: 'basic'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['optimization_report']).to be_present
        report = json['optimization_report']
        expect(report['statistics']).to be_present
        expect(report['statistics']['original_gate_count']).to be_an(Integer)
        expect(report['statistics']['optimized_gate_count']).to be_an(Integer)
      end

      it 'optimizes with aggressive level' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          optimization_level: 'aggressive'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        report = json['optimization_report']
        # Aggressive optimization should provide more reduction
        expect(report['statistics']['reduction_percent']).to be >= 0
      end

      it 'skips optimization when include_optimization is false' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          include_optimization: false
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['optimization_report']).to be_nil
      end

      it 'includes optimization statistics' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          optimization_level: 'basic'
        }, as: :json

        json = response.parsed_body
        stats = json['optimization_report']['statistics']
        expect(stats['original_gate_count']).to be > 0
        expect(stats['optimized_gate_count']).to be > 0
        expect(stats['reduction_percent']).to be_between(0, 100)
      end
    end

    context 'with timing analysis' do
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

      it 'performs timing analysis with default frequency' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json'
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['timing_analysis']).to be_present
        timing = json['timing_analysis']
        expect(timing['summary']).to be_present
      end

      it 'performs timing analysis at specified frequency' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          clock_freq_mhz: 200
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        timing = json['timing_analysis']
        expect(timing['summary']['target_frequency_mhz']).to eq(200)
      end

      it 'skips timing analysis when include_timing is false' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          include_timing: false
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['timing_analysis']).to be_nil
      end

      it 'includes timing summary with closure status' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          clock_freq_mhz: 100
        }, as: :json

        json = response.parsed_body
        summary = json['timing_analysis']['summary']
        expect(summary['timing_closure']).to be_in(['PASS', 'FAIL'])
        expect(summary['num_violations']).to be >= 0
      end

      it 'identifies critical paths' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          clock_freq_mhz: 100
        }, as: :json

        json = response.parsed_body
        timing = json['timing_analysis']
        expect(timing['critical_paths']).to be_present
        expect(timing['critical_paths']).to be_an(Array)
      end

      it 'provides timing recommendations' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          clock_freq_mhz: 500
        }, as: :json

        json = response.parsed_body
        timing = json['timing_analysis']
        expect(timing['recommendations']).to be_present
        expect(timing['recommendations']).to be_an(Array)
      end

      it 'rejects invalid clock frequency' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          clock_freq_mhz: -100
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = response.parsed_body
        expect(json['errors']).to include('positive')
      end

      it 'rejects invalid diagram layout' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          diagram_layout: 'invalid_layout'
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'rejects invalid optimization level' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          optimization_level: 'invalid_level'
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with all features combined' do
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

      it 'combines diagram, optimization, and timing' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'gray',
          flip_flop_type: 'jk',
          reset_type: 'synchronous',
          diagram_layout: 'hierarchy',
          optimization_level: 'aggressive',
          clock_freq_mhz: 100
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        
        # Check basic synthesis
        expect(json['machine_type']).to eq('moore')
        expect(json['flip_flop_type']).to eq('jk')
        
        # Check diagram
        expect(json['diagram']).to be_present
        expect(json['diagram']['metadata']['layout']).to eq('hierarchy')
        
        # Check optimization
        expect(json['optimization_report']).to be_present
        
        # Check timing
        expect(json['timing_analysis']).to be_present
        expect(json['timing_analysis']['summary']['target_frequency_mhz']).to eq(100)
      end

      it 'combines with async inputs, diagram, and timing' do
        post '/api/v1/fsm_synthesize', params: {
          fsm_data: moore_json,
          format: 'json',
          encoding: 'binary',
          diagram_layout: 'circle',
          optimization_level: 'basic',
          clock_freq_mhz: 150,
          sync_inputs: [
            {
              input_name: 'external_input',
              src_clock: 'clk_src',
              dest_clock: 'clk_sys'
            }
          ]
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        
        expect(json['synchronizers']).to be_present
        expect(json['diagram']).to be_present
        expect(json['optimization_report']).to be_present
        expect(json['timing_analysis']).to be_present
      end
    end
  end
end
