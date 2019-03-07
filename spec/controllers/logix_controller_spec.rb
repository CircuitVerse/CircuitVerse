# frozen_string_literal: true

require 'rails_helper'

describe LogixController, type: :request do
  before do
    FactoryBot.create(:project1)
    FactoryBot.create(:project2)
    FactoryBot.create(:project3)
    FactoryBot.create(:project4)
  end
  it  'should get index page' do
    get root_path
    expect(response.status).to eq(200)
  end
  it  'should get gettingStarted' do
    get gettingStarted_path
    expect(response.status).to eq(200)
  end
  it  'should get examples page' do
    get examples_path
    expect(response.status).to eq(200)
  end
  it  'should get features page' do
    get features_path
    expect(response.status).to eq(200)
  end
  it  'should get about page' do
    get about_path
    expect(response.status).to eq(200)
  end
  it  'should get privacy page' do
    get privacy_path
    expect(response.status).to eq(200)
  end
  it  'should get tos page' do
    get tos_path
    expect(response.status).to eq(200)
  end
  it  'should get teachers page' do
    get teachers_path
    expect(response.status).to eq(200)
  end
  it  'should get contribute page' do
    get contribute_path
    expect(response.status).to eq(200)
  end
  it  'should get search results' do
    get search_path, params:{q:"basic gates"}
    @projects = @controller.instance_variable_get(:@projects).to_a
    expect(response.status).to eq(200)
    expect(@projects).to     match_array(Project.first(3))
  end
end
