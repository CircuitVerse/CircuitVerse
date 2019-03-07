# frozen_string_literal: true

require 'rails_helper'

describe LogixController, type: :request do

  it 'should get index page' do
    get root_path
    expect(response.status).to eq(200)
  end

  it 'should get gettingStarted' do
    get gettingStarted_path
    expect(response.status).to eq(200)
  end

  it 'should get examples page' do
    get examples_path
    expect(response.status).to eq(200)
  end

  it 'should get features page' do
    get features_path
    expect(response.status).to eq(200)
  end

  it 'should get about page' do
    get about_path
    expect(response.status).to eq(200)
  end

  it 'should get privacy page' do
    get privacy_path
    expect(response.status).to eq(200)
  end

  it 'should get tos page' do
    get tos_path
    expect(response.status).to eq(200)
  end

  it 'should get teachers page' do
    get teachers_path
    expect(response.status).to eq(200)
  end

  it 'should get contribute page' do
    get contribute_path
    expect(response.status).to eq(200)
  end

  it 'should get some results' do
    FactoryBot.create(:project, name: 'Full adder using basic gates')
    FactoryBot.create(:project, name: 'Half adder using basic gates')
    FactoryBot.create(:project, name: 'Full adder using half adder')
    get search_path, params: {q: 'basic gates'}
    expect(response.status).to eq(200)
    expect(response.body).to include 'Full adder using basic gates'
    expect(response.body).to include 'Half adder using basic gates'
    expect(response.body).not_to include 'Full adder using half adder'
  end

  it 'should get no results' do
    FactoryBot.create(:project, name: 'Full adder using basic gates')
    get search_path, params: {q: 'half adder'}
    expect(response.status).to eq(200)
    expect(response.body).not_to include 'Full adder using basic gates'
    expect(response.body).to include 'No Results Found'
  end
end
