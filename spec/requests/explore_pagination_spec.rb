# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore pagination (cursor)", type: :request do
  let(:recent_limit) { ExploreController::RECENT_LIMIT }

  before do
    Flipper.enable(:circuit_explore_page)
  end

  def extract_cursor(body, key)
    m = body.match(%r{href="/explore\?section=recent&amp;#{key}=([^"#&]+)})
    m && m[1]
  end

  context "with no projects" do
    it "renders empty state and no pagination" do
      get "/explore"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nothing to show yet.")
      expect(response.body).not_to include("pagination justify-content-center")
    end
  end

  context "with many projects" do
    let!(:author) { FactoryBot.create(:user) }

    before do
      FactoryBot.create_list(:project, 25, :public, author: author, image_preview: "x.png")
    end

    it "first page has next (after=) but no prev (before=)" do
      get "/explore"
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('href="/explore?section=recent&amp;before=')
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;after=[^"&]+})
    end

    it "next page via after has both prev (before=) and next (after=)" do
      get "/explore"
      after_cursor = extract_cursor(response.body, "after")
      expect(after_cursor).to be_present

      get "/explore", params: { section: "recent", after: after_cursor }
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;after=[^"&]+})
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;before=[^"&]+})
    end

    it "previous page via before returns newer set" do
      get "/explore"
      after_cursor = extract_cursor(response.body, "after")
      get "/explore", params: { section: "recent", after: after_cursor }
      before_cursor = extract_cursor(response.body, "before")
      expect(before_cursor).to be_present

      get "/explore", params: { section: "recent", before: before_cursor }
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('href="/explore?section=recent&amp;before=')
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;after=[^"&]+})
    end

    it "middle page via before has both prev and next" do
      get "/explore"
      a1 = extract_cursor(response.body, "after")
      get "/explore", params: { section: "recent", after: a1 }
      a2 = extract_cursor(response.body, "after")
      get "/explore", params: { section: "recent", after: a2 }
      b3 = extract_cursor(response.body, "before")
      get "/explore", params: { section: "recent", before: b3 }

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;after=[^"&]+})
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;before=[^"&]+})
    end

    it "last page has prev (before=) but no next (after=)" do
      get "/explore"
      a1 = extract_cursor(response.body, "after")
      expect(a1).to be_present
      get "/explore", params: { section: "recent", after: a1 }

      a2 = extract_cursor(response.body, "after")
      expect(a2).to be_present
      get "/explore", params: { section: "recent", after: a2 }

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to match(%r{href="/explore\?section=recent&amp;after=[^"&]+})
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;before=[^"&]+})
    end

    it "gracefully handles malformed 'after' cursor (falls back to first page state)" do
      get "/explore", params: { section: "recent", after: "!!not-a-cursor!!" }
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('href="/explore?section=recent&amp;before=')
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;after=[^"&]+})
    end

    it "gracefully handles malformed 'before' cursor (falls back to first page state)" do
      get "/explore", params: { section: "recent", before: "!!not-a-cursor!!" }
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('href="/explore?section=recent&amp;before=')
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;after=[^"&]+})
    end
  end
end
