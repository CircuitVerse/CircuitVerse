# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#index pagination", type: :request do
  before { FactoryBot.create_list(:project, 3, project_access_type: "Public") }

  def request_projects(query)
    get "/api/v1/projects?#{query}", as: :json
    response.parsed_body
  end

  it "falls back to the first page when page[number] is zero" do
    body = request_projects("page[number]=0")

    expect(response).to have_http_status(:ok)
    expect(body["data"].length).to eq(3)
    expect(body["links"]["self"]).to include("page[number]=1")
  end

  it "falls back to the first page when page[number] is not a number" do
    request_projects("page[number]=abc")

    expect(response).to have_http_status(:ok)
  end

  it "uses the default page size when page[size] is zero" do
    body = request_projects("page[size]=0")

    expect(response).to have_http_status(:ok)
    expect(body["data"].length).to eq(3)
  end

  it "respects a valid page[size]" do
    body = request_projects("page[size]=2")

    expect(body["data"].length).to eq(2)
    expect(body["links"]["next"]).to include("page[number]=2")
  end

  it "caps page[size] at MAX_PER_PAGE" do
    get "/api/v1/projects?page[size]=100000", as: :json

    expect(response).to have_http_status(:ok)
    expect(controller.instance_variable_get(:@pagy).limit).to eq(Api::V1::BaseController::MAX_PER_PAGE)
  end

  it "returns an empty page past the last page" do
    body = request_projects("page[number]=99")

    expect(response).to have_http_status(:ok)
    expect(body["data"]).to be_empty
  end
end
