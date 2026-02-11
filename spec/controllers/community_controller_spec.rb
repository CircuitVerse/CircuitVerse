# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommunityController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns stats' do
      get :index
      expect(assigns(:stats)).to be_present
      expect(assigns(:stats)).to have_key(:total_users)
      expect(assigns(:stats)).to have_key(:total_projects)
      expect(assigns(:stats)).to have_key(:total_contributions)
      expect(assigns(:stats)).to have_key(:active_users_last_month)
    end

    it 'assigns recent projects' do
      project = create(:project, author: user)
      get :index
      expect(assigns(:recent_projects)).to include(project)
    end

    it 'assigns top contributors' do
      get :index
      expect(assigns(:top_contributors)).to be_present
    end
  end

  describe 'GET #leaderboard' do
    it 'returns a success response' do
      get :leaderboard
      expect(response).to be_successful
    end

    it 'assigns time period' do
      get :leaderboard, params: { period: 'monthly' }
      expect(assigns(:time_period)).to eq('monthly')
    end

    it 'defaults to weekly period' do
      get :leaderboard
      expect(assigns(:time_period)).to eq('weekly')
    end

    it 'assigns leaderboard data' do
      get :leaderboard
      expect(assigns(:leaderboard_data)).to be_present
      expect(assigns(:leaderboard_data)).to be_an(Array)
    end

    it 'assigns current user rank' do
      get :leaderboard
      expect(assigns(:current_user_rank)).to be_present
    end
  end

  describe 'private methods' do
    let(:controller_instance) { described_class.new }

    before do
      allow(controller_instance).to receive(:params).and_return({})
    end

    describe '#set_time_period' do
      it 'sets valid time period' do
        allow(controller_instance).to receive(:params).and_return({ period: 'monthly' })
        controller_instance.send(:set_time_period)
        expect(controller_instance.instance_variable_get(:@time_period)).to eq('monthly')
      end

      it 'defaults to weekly for invalid period' do
        allow(controller_instance).to receive(:params).and_return({ period: 'invalid' })
        controller_instance.send(:set_time_period)
        expect(controller_instance.instance_variable_get(:@time_period)).to eq('weekly')
      end
    end

    describe '#get_top_contributors' do
      it 'returns users with contribution points' do
        contributors = controller_instance.send(:get_top_contributors, 'all_time', 10)
        expect(contributors).to be_an(ActiveRecord::Relation)
      end
    end
  end
end
