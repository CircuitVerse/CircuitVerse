require 'rails_helper'

describe SimulatorController ,type: :request do
  before do
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project , author: @user)
  end

  describe 'should create empty project'  do
    before do
      sign_in @user
    end

    it "#create" do
      post "/simulator/create_data",params: {image: ""}
      expect(response.status).to eq(302)

    end

    it "#update" do
      post "/simulator/update_data",params: {id: @project.id ,image: ""}
      expect(response.status).to eq(200)

    end
  end
end

