# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Project page preview meta tags", type: :request do
  let(:author) { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project, author: author, project_access_type: "Public") }

  it "uses the ActiveStorage preview for og:image" do
    project.circuit_preview.attach(io: Rails.root.join("spec/fixtures/files/profile.png").open,
                                   filename: "preview.png", content_type: "image/png")

    get user_project_path(author, project)

    og_image = response.parsed_body.at_css("meta[property='og:image']")["content"]
    expect(og_image).to eq("#{Rails.configuration.site_url}#{project.preview_path}")
    expect(og_image).to include("/rails/active_storage/blobs/")
  end

  it "falls back to the default image when no preview exists" do
    get user_project_path(author, project)

    og_image = response.parsed_body.at_css("meta[property='og:image']")["content"]
    expect(og_image).to eq("#{Rails.configuration.site_url}/images/default.png")
  end
end
