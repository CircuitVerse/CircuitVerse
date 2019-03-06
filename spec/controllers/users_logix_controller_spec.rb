# frozen_string_literal: true

require 'rails_helper'

describe Users::LogixController, type: :request do
  before do
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  it  'should get user projects' do
    get user_projects_path(:id => @user.id)
    expect(response.status).to eq(200)
  end
  it  'should get user profile' do
    get profile_path(:id => @user.id)
    expect(response.status).to eq(200)
  end
  it  'should get user favourites' do
    get user_favourites_path(:id => @user.id)
    expect(response.status).to eq(200)
  end
  it  'should get user groups' do
    get user_groups_path(:id => @user.id)
    expect(response.status).to eq(200)
  end
  it 'should get edit profile' do
    get profile_edit_path(:id => @user.id)
    expect(response.status).to eq(200)
  end

  it 'should update user profile' do
    patch profile_update_path(@user), params:{id:@user.id,user:{"name"=>"Jd", "country"=>"IN", "educational_institute"=>"MAIT"}}
    expect(response).to redirect_to(profile_path(:id => @user.id))
    expect(@user.name).to eq('Jd')
    expect(@user.country).to eq('IN')
    expect(@user.educational_institute).to eq('MAIT')
  end
end
