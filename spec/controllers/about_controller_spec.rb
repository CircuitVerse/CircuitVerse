# frozen_string_literal: true

require "rails_helper"

describe AboutController, type: :controller do
  describe 'GET #index' do
    before { get :index }

    it 'returns a success response' do
      expect(response).to be_successful
    end

    it 'assigns core team members' do
      expect(assigns(:cores)).to be_an(Array)
      expect(assigns(:cores).length).to be > 0
      expect(assigns(:cores).first).to have_key(:name)
      expect(assigns(:cores).first).to have_key(:img)
      expect(assigns(:cores).first).to have_key(:link)
    end

    it 'assigns mentors array' do
      expect(assigns(:mentors)).to be_an(Array)
      expect(assigns(:mentors)).to be_empty
    end

    it 'assigns alumni members' do
      expect(assigns(:alumni)).to be_an(Array)
      expect(assigns(:alumni).length).to be > 0
      expect(assigns(:alumni).first).to have_key(:name)
      expect(assigns(:alumni).first).to have_key(:img)
      expect(assigns(:alumni).first).to have_key(:link)
    end

    it 'assigns issues triaging array' do
      expect(assigns(:issues_triaging)).to be_an(Array)
      expect(assigns(:issues_triaging)).to be_empty
    end

    it 'assigns top contributors with enhanced data' do
      expect(assigns(:top_contributors)).to be_an(Array)
      expect(assigns(:top_contributors).length).to be > 0
      
      first_contributor = assigns(:top_contributors).first
      expect(first_contributor).to have_key(:name)
      expect(first_contributor).to have_key(:username)
      expect(first_contributor).to have_key(:avatar)
      expect(first_contributor).to have_key(:contributions)
      expect(first_contributor).to have_key(:role)
      expect(first_contributor).to have_key(:github_url)
      expect(first_contributor).to have_key(:bio)
      expect(first_contributor).to have_key(:location)
      expect(first_contributor).to have_key(:website)
    end

    it 'renders the index template' do
      expect(response).to render_template(:index)
    end
  end

  describe 'Contributors Data Structure' do
    it 'has valid core team members data' do
      get :index
      cores = assigns(:cores)
      
      cores.each do |member|
        expect(member[:name]).to be_a(String)
        expect(member[:img]).to be_a(String)
        expect(member[:link]).to be_a(String)
        expect(member[:img]).to match(/https:\/\/avatars\.githubusercontent\.com/)
        expect(member[:link]).to match(/https:\/\/github\.com/)
      end
    end

    it 'has valid top contributors data' do
      get :index
      contributors = assigns(:top_contributors)
      
      contributors.each do |contributor|
        expect(contributor[:name]).to be_a(String)
        expect(contributor[:username]).to be_a(String)
        expect(contributor[:avatar]).to be_a(String)
        expect(contributor[:contributions]).to be_a(Integer)
        expect(contributor[:role]).to be_a(String)
        expect(contributor[:github_url]).to be_a(String)
        expect(contributor[:bio]).to be_a(String)
        expect(contributor[:location]).to be_a(String)
        expect(contributor[:website]).to be_a(String)
        
        expect(contributor[:avatar]).to match(/https:\/\/avatars\.githubusercontent\.com/)
        expect(contributor[:github_url]).to match(/https:\/\/github\.com/)
        expect(contributor[:contributions]).to be > 0
      end
    end
  end

  describe 'Performance Considerations' do
    it 'does not make external API calls during request' do
      expect { get :index }.not_to make_http_requests
    end

    it 'assigns reasonable data sizes' do
      get :index
      
      expect(assigns(:cores).length).to be <= 20
      expect(assigns(:top_contributors).length).to be <= 10
      expect(assigns(:alumni).length).to be <= 30
    end
  end
end
