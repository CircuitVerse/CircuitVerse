# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ReleasesController, type: :request do
  describe 'GET #index' do
    it 'returns releases data' do
      get '/api/v1/releases'
      
      expect(response).to be_successful
      expect(response.parsed_body).to have_key(:circuitverse)
      expect(response.parsed_body).to have_key(:vue_simulator)
      expect(response.parsed_body).to have_key(:last_updated)
      expect(response.parsed_body).to have_key(:total_releases)
    end
  end

  describe 'GET #circuitverse' do
    it 'returns circuitverse releases' do
      get '/api/v1/releases/circuitverse'
      
      expect(response).to be_successful
      expect(response.parsed_body).to be_an(Array)
    end
  end

  describe 'GET #vue_simulator' do
    it 'returns vue simulator releases' do
      get '/api/v1/releases/vue-simulator'
      
      expect(response).to be_successful
      expect(response.parsed_body).to be_an(Array)
    end
  end
end
