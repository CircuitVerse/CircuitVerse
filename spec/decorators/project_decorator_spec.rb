# frozen_string_literal: true

require "rails_helper"

describe ProjectDecorator do
  def decorated_project
    ProjectDecorator.new(@project)
  end

  before do
    @project = FactoryBot.create(:project, author: FactoryBot.create(:user))
  end

  describe "#grade_str" do
    context "project has been graded" do
      it "gives grade string" do
        FactoryBot.build(:grade, project: @project, grade: "A")
        expect(decorated_project.grade_str).to eq("A")
      end
    end

    context "project has not been graded" do
      it "gives grade n.a." do
        expect(decorated_project.grade_str).to eq("N.A.")
      end
    end
  end
end
