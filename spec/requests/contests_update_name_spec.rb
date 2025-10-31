# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Contests#update (Name)", type: :request do
  
  let(:admin)   { create(:user, admin: true) }
  
  let(:contest) do
    live_contest = create(:contest, :live)
    live_contest.update_column(:name, "Original Contest Name")
    live_contest
  end

  before { sign_in admin; enable_contests! }

  context "successful name update" do
    it "updates the name and redirects to admin index with success notice" do
      new_name = "The Ultimate New Name Challenge"
      patch admin_contest_path(contest), params: { 
        contest: { name: new_name }
      }
      expect(response).to redirect_to(admin_contests_path)
      expect(flash[:notice]).to eq("Contest name was successfully updated.")
      expect(contest.reload.name).to eq(new_name)
    end
  end

  context "invalid name submission" do
    it "rejects blank name and redirects with a validation error alert" do
      patch admin_contest_path(contest), params: { 
        contest: { name: "" }
      }
      expect(contest.reload.name).to eq("Original Contest Name") 
      expect(response).to redirect_to(admin_contests_path)
      expect(flash[:alert]).to include("Failed to update contest name: Name can't be blank")
    end
  end
  
  context "save failure branch" do
    it "redirects with generic failure alert when update fails internally" do
      allow_any_instance_of(Contest).to receive(:update).and_return(false)
      patch admin_contest_path(contest), params: { 
        contest: { name: "Test Name That Fails" }
      }
      expect(response).to redirect_to(admin_contests_path)
      expect(flash[:alert]).to match(/Failed to update contest name/)
    end
  end
  
  # === Authorization Guard ===
  context "when not authenticated" do
    it "redirects to sign in" do
      sign_out admin 
      patch admin_contest_path(contest), params: { contest: { name: "Unauthorized Change" } }
      expect(response).to redirect_to(new_user_session_path)
      expect(contest.reload.name).to eq("Original Contest Name")
    end
  end
end