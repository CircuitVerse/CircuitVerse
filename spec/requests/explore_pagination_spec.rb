# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Explore pagination (cursor)", type: :request do
  let(:recent_limit) { ExploreController::RECENT_LIMIT }

  before do
    Flipper.enable(:circuit_explore_page)
  end

  context "with no projects" do
    it "renders empty state and no pagination" do
      get "/explore"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("explore.empty"))
      expect(response.body).not_to include("pagination justify-content-center")
    end
  end

  context "with many projects" do
    let!(:author) { FactoryBot.create(:user) }

    before do
      Array.new(25) do
        FactoryBot.create(:project, author: author, project_access_type: "Public", image_preview: "x.png")
      end
    end

    def base_scope
      Project.select(:id, :author_id, :image_preview, :name, :slug, :view, :description)
             .public_and_not_forked
             .where.not(image_preview: "default.png")
    end

    it "first page has next but no prev" do
      get "/explore"
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('href="/explore?section=recent&amp;after_id=')
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;before_id=\d+"})
    end

    it "next page via before_id has both prev and next" do
      get "/explore"
      expect(response).to have_http_status(:ok)
      m = response.body.match(%r{href="/explore\?section=recent&amp;before_id=(\d+)"})
      expect(m).not_to be_nil
      before_id = m[1]

      get "/explore", params: { section: "recent", before_id: before_id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;after_id=\d+"})
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;before_id=\d+"})
    end

    it "previous page via after_id returns newer set" do
      page1_last = base_scope.order(id: :desc).limit(recent_limit).pluck(:id).last
      page2_ids  = base_scope.where(Project.arel_table[:id].lt(page1_last))
                             .order(id: :desc).limit(recent_limit).pluck(:id)
      after_id = page2_ids.first
      get "/explore", params: { section: "recent", after_id: after_id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;before_id=\d+"})
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "middle page via after_id has both prev and next (covers reverse branch)" do
      get "/explore"
      m1 = response.body.match(%r{href="/explore\?section=recent&amp;before_id=(\d+)"})
      expect(m1).not_to be_nil
      b1 = m1[1]

      get "/explore", params: { section: "recent", before_id: b1 }
      expect(response).to have_http_status(:ok)
      m2_next = response.body.match(%r{href="/explore\?section=recent&amp;before_id=(\d+)"})
      expect(m2_next).not_to be_nil
      b2 = m2_next[1]

      get "/explore", params: { section: "recent", before_id: b2 }
      expect(response).to have_http_status(:ok)
      m3_prev = response.body.match(%r{href="/explore\?section=recent&amp;after_id=(\d+)"})
      expect(m3_prev).not_to be_nil
      a3 = m3_prev[1]

      get "/explore", params: { section: "recent", after_id: a3 }
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;after_id=\d+"})
      expect(response.body).to match(%r{href="/explore\?section=recent&amp;before_id=\d+"})
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
