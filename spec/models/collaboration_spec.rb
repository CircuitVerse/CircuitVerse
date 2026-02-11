# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collaboration, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
  end

  describe "validations" do
    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project) }

    it "is valid with a user and a project" do
      collaboration = Collaboration.new(user: user, project: project)
      expect(collaboration).to be_valid
    end

    it "is invalid without a user" do
      collaboration = Collaboration.new(user: nil, project: project)
      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:user]).to include("must exist")
    end

    it "is invalid without a project" do
      collaboration = Collaboration.new(user: user, project: nil)
      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:project]).to include("must exist")
    end

    it "validates uniqueness of user scoped to project" do
      Collaboration.create!(user: user, project: project)
      duplicate = Collaboration.new(user: user, project: project)
      
      expect(duplicate).not_to be_valid
      
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end
    
    it "is invalid if the user is already the owner of the project" do
      owner = project.author
      collaboration = Collaboration.new(user: owner, project: project)
      
      expect(collaboration).not_to be_valid
      
      expect(collaboration.errors[:user]).to include("cannot be the owner of the project")
    end
  end
end