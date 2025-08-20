# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tags pagination (cursor)", type: :request do
  let(:per_page) { ExploreController::RECENT_LIMIT }

  before do
    Flipper.enable(:circuit_explore_page)
  end

  def extract_cursor(body, key, tag_name:)
    pattern = %r{href="/projects/tags/#{Regexp.escape(tag_name)}\?#{key}=([^"#&]+)}
    m = body.match(pattern)
    m && m[1]
  end

  context "with a tag that has no projects" do
    it "renders empty state and no pagination" do
      tag = FactoryBot.create(:tag, name: "logic")
      get "/projects/tags/#{tag.name}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nothing to show yet.")
      expect(response.body).not_to include("pagination justify-content-center")
    end
  end

  context "with many tagged projects" do
    let!(:author) { FactoryBot.create(:user) }
    let!(:tag)    { FactoryBot.create(:tag, name: "logic") }

    before do
      FactoryBot.create_list(:project, 25, :public, author: author, image_preview: "x.png").each do |proj|
        FactoryBot.create(:tagging, project: proj, tag: tag)
      end
    end

    it "first page has next (after=) but no prev (before=)" do
      get "/projects/tags/#{tag.name}"
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(%(href="/projects/tags/#{tag.name}&amp;before=))
      expect(response.body).to match(%r{href="/projects/tags/#{tag.name}\?after=[^"&]+})
    end

    it "next page via after has both prev (before=) and next (after=)" do
      get "/projects/tags/#{tag.name}"
      after_cursor = extract_cursor(response.body, "after", tag_name: tag.name)
      expect(after_cursor).to be_present

      get "/projects/tags/#{tag.name}", params: { after: after_cursor }
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(%r{href="/projects/tags/#{tag.name}\?after=[^"&]+})
      expect(response.body).to match(%r{href="/projects/tags/#{tag.name}\?before=[^"&]+})
    end

    it "previous page via before returns newer set" do
      get "/projects/tags/#{tag.name}"
      after_cursor = extract_cursor(response.body, "after", tag_name: tag.name)
      get "/projects/tags/#{tag.name}", params: { after: after_cursor }
      before_cursor = extract_cursor(response.body, "before", tag_name: tag.name)
      expect(before_cursor).to be_present

      get "/projects/tags/#{tag.name}", params: { before: before_cursor }
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(%(href="/projects/tags/#{tag.name}&amp;before=))
      expect(response.body).to match(%r{href="/projects/tags/#{tag.name}\?after=[^"&]+})
    end

    it "middle page via before has both prev and next" do
      get "/projects/tags/#{tag.name}"
      a1 = extract_cursor(response.body, "after", tag_name: tag.name)
      get "/projects/tags/#{tag.name}", params: { after: a1 }
      a2 = extract_cursor(response.body, "after", tag_name: tag.name)
      get "/projects/tags/#{tag.name}", params: { after: a2 }
      b3 = extract_cursor(response.body, "before", tag_name: tag.name)
      get "/projects/tags/#{tag.name}", params: { before: b3 }

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(%r{href="/projects/tags/#{tag.name}\?after=[^"&]+})
      expect(response.body).to match(%r{href="/projects/tags/#{tag.name}\?before=[^"&]+})
    end

    it "last page has prev (before=) but no next (after=)" do
      get "/projects/tags/#{tag.name}"
      a1 = extract_cursor(response.body, "after", tag_name: tag.name)
      expect(a1).to be_present
      get "/projects/tags/#{tag.name}", params: { after: a1 }

      a2 = extract_cursor(response.body, "after", tag_name: tag.name)
      expect(a2).to be_present
      get "/projects/tags/#{tag.name}", params: { after: a2 }

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to match(%r{href="/projects/tags/#{tag.name}\?after=[^"&]+})
      expect(response.body).to match(%r{href="/projects/tags/#{tag.name}\?before=[^"&]+})
    end

    it "gracefully handles malformed 'after' cursor (falls back to first page state)" do
      get "/projects/tags/#{tag.name}", params: { after: "!!not-a-cursor!!" }
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(%(href="/projects/tags/#{tag.name}&amp;before=))
      expect(response.body).to match(%r{href="/projects/tags/#{tag.name}\?after=[^"&]+})
    end

    it "gracefully handles malformed 'before' cursor (falls back to first page state)" do
      get "/projects/tags/#{tag.name}", params: { before: "!!not-a-cursor!!" }
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(%(href="/projects/tags/#{tag.name}&amp;before=))
      expect(response.body).to match(%r{href="/projects/tags/#{tag.name}\?after=[^"&]+})
    end
  end
end
