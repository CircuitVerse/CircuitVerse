# frozen_string_literal: true

require "rails_helper"

RSpec.describe "config/sitemap.rb" do
  let(:user_with_public_projects) { FactoryBot.create(:user, current_sign_in_at: 10.days.ago) }
  let(:user_without_public_projects) { FactoryBot.create(:user, current_sign_in_at: 1.day.ago) }
  let(:user_never_signed_in) { FactoryBot.create(:user, current_sign_in_at: nil) }
  let!(:public_project) do
    FactoryBot.create(:project, author: user_with_public_projects, project_access_type: "Public", updated_at: 2.days.ago)
  end
  let!(:private_project) do
    FactoryBot.create(:project, author: user_without_public_projects, project_access_type: "Private", updated_at: 1.hour.ago)
  end

  it "uses the latest public project updated_at as lastmod and omits lastmod when none exist" do
    allow(SitemapGenerator::Sitemap).to receive(:create).and_wrap_original do |_original_method, &block|
      context = double("SitemapContext")
      allow(context).to receive(:user_projects_path) { |user| "/users/#{user.id}" }
      allow(context).to receive(:user_project_path) { |author, project| "/users/#{author.id}/projects/#{project.id}" }
      allow(context).to receive(:about_index_path).and_return("/about")
      allow(context).to receive(:featured_circuits_path).and_return("/featured")
      allow(context).to receive(:simulator_new_path).and_return("/simulator")
      allow(context).to receive(:examples_path).and_return("/examples")
      allow(context).to receive(:privacy_index_path).and_return("/privacy")
      allow(context).to receive(:contribute_path).and_return("/contribute")
      allow(context).to receive(:teachers_path).and_return("/teachers")

      expect(context).to receive(:add).with("/users/#{user_with_public_projects.id}", lastmod: public_project.updated_at)
      expect(context).to receive(:add).with("/users/#{user_without_public_projects.id}")
      expect(context).to receive(:add).with("/users/#{user_never_signed_in.id}")
      allow(context).to receive(:add)

      context.instance_eval(&block)
    end

    load Rails.root.join("config/sitemap.rb")
  end
end
