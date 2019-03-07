require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "associations" do
    it { should belong_to(:author) }
    it { should belong_to(:assignment).optional }
    it { should belong_to(:forked_project).optional }
    it { should have_many(:forks) }
    it { should have_many(:stars) }
    it { should have_many(:collaborations) }
    it { should have_many(:collaborators) }
  end

  describe "validity" do
    before do
      @user = FactoryBot.create(:user)
      group = FactoryBot.create(:group, mentor: @user)
      @assignment = FactoryBot.create(:assignment, group: group)
    end

    it "doesn't validate with public access type" do
      project = FactoryBot.build(:project, assignment: @assignment, author: @user)
      expect(project).to be_valid
      project.project_access_type = 'Public'
      expect(project).to be_invalid
    end
  end
end
