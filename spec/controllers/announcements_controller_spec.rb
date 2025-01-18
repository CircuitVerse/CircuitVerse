# frozen_string_literal: true

require "rails_helper"

RSpec.describe AnnouncementsController, type: :request do
  before do
    @announcement = FactoryBot.create(:announcement,
                                      body: "Test Announcement", link: "Test Link",
                                      start_date: "2020-10-21", end_date: "2020-10-21")
  end

  context "when admin is signed in" do
    before do
      sign_in FactoryBot.create(:user, admin: true)
    end

    describe "#create" do
      let(:create_params) do
        {
          announcement: {
            body: "Test Announcement",
            link: "Test Link",
            start_date: "2020-10-21",
            end_date: "2020-10-21"
          }
        }
      end

      it "creates a new announcement" do
        expect { (post announcements_path, params: create_params) }
          .to change(Announcement, :count).by(1)
      end
    end

    describe "#update" do
      let(:update_params) do
        {
          announcement: {
            body: "Updated Announcement",
            link: "Updated Link",
            start_date: "2020-10-22",
            end_date: "2020-10-22"
          }
        }
      end

      it "updates announcements" do
        expect do
          put announcement_path(@announcement), params: update_params
          @announcement.reload
        end.to change { @announcement.body }
          .to("Updated Announcement")
          .and change { @announcement.link }
          .to("Updated Link")
          .and change { @announcement.start_date.strftime("%Y-%m-%d") }
          .to("2020-10-22")
          .and change { @announcement.end_date.strftime("%Y-%m-%d") }.to("2020-10-22")
      end
    end

    describe "#index" do
      it "shows the list of created announcements" do
        get announcements_path(@announcement)
        expect(response.status).to eq(200)
        expect(response.body).to include(@announcement.body)
      end
    end

    describe "#edit" do
      it "shows the details of the announcement for edit" do
        get edit_announcement_path(@announcement)
        expect(response.status).to eq(200)
        expect(response.body).to include(@announcement.body)
      end
    end

    describe "#destroy" do
      it "deletes the announcement" do
        expect { delete announcement_path(@announcement) }
          .to change(Announcement, :count).by(-1)
      end
    end
  end

  context "when user is not admin" do
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in user
    end

    it "returns 'not authorized' for the #index route" do
      get announcements_path(@announcement)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 'not authorized' for the #update route" do
      put announcement_path(@announcement), params: { announcement: {} }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 'not authorized' for the #create route" do
      post announcements_path, params: { announcement: {} }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 'not authorized' for the #destroy route" do
      delete announcement_path(@announcement)
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
