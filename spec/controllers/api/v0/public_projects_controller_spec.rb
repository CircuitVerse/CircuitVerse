require "rails_helper"

describe API::V0::PublicProjectsController do
  let(:author) { create(:user) }
  let(:projects) {create_list(:project, 5, project_access_type: "Public")}
  let(:project) {create(:project, project_access_type: "Public")}

  describe "#index" do
    subject {get :index}

    before { author }

    it {  is_expected.to be_successful }
    it 'returns public projects' do
      body = JSON.parse(subject.body)
      expect(body['data'][0]['type']).to eq('project')
    end
  end
end
