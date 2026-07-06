# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::SubgroupsController, "#update_members", type: :request do
  describe "sync subgroup members" do
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, primary_mentor: mentor) }
    let!(:subgroup) { FactoryBot.create(:group, name: "Team A", parent_group: group) }
    let!(:student_a) { FactoryBot.create(:user) }
    let!(:student_b) { FactoryBot.create(:user) }

    before do
      FactoryBot.create(:group_member, group: group, user: student_a)
      FactoryBot.create(:group_member, group: group, user: student_b)
    end

    context "when the mentor sets the membership" do
      before do
        token = get_auth_token(mentor)
        patch "/api/v1/subgroups/#{subgroup.id}/members",
              headers: { Authorization: "Token #{token}" },
              params: { user_ids: [student_a.id, student_b.id] }, as: :json
      end

      it "adds the selected parent members" do
        expect(response).to have_http_status(:accepted)
        expect(subgroup.reload.group_members.pluck(:user_id))
          .to contain_exactly(student_a.id, student_b.id)
      end
    end

    context "when a user is submitted who is not in the parent group" do
      before do
        outsider = FactoryBot.create(:user)
        token = get_auth_token(mentor)
        patch "/api/v1/subgroups/#{subgroup.id}/members",
              headers: { Authorization: "Token #{token}" },
              params: { user_ids: [outsider.id, student_a.id] }, as: :json
      end

      it "ignores the outsider" do
        expect(subgroup.reload.group_members.pluck(:user_id)).to contain_exactly(student_a.id)
      end
    end

    context "when a submitted user already holds a mentor row in the subgroup" do
      before do
        FactoryBot.create(:group_member, group: subgroup, user: student_a, mentor: true)
        token = get_auth_token(mentor)
        patch "/api/v1/subgroups/#{subgroup.id}/members",
              headers: { Authorization: "Token #{token}" },
              params: { user_ids: [student_a.id, student_b.id] }, as: :json
      end

      it "does not duplicate the row" do
        expect(response).to have_http_status(:accepted)
        expect(subgroup.reload.group_members.where(user_id: student_a.id).count).to eq(1)
      end
    end

    context "when a regular member tries to change membership" do
      before do
        token = get_auth_token(student_a)
        patch "/api/v1/subgroups/#{subgroup.id}/members",
              headers: { Authorization: "Token #{token}" },
              params: { user_ids: [student_b.id] }, as: :json
      end

      it "returns forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
