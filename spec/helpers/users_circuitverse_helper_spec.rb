# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersCircuitverseHelper, type: :helper do
  describe "#get_priority_countries" do
    let(:mock_geocoder_result) { instance_double(Geocoder::Result::Base) }

    before do
      allow(Geocoder).to receive(:search).and_return([mock_geocoder_result])
    end

    context "when the remote IP is geocoded to a priority country" do
      before do
        allow(mock_geocoder_result).to receive(:country).and_return("IN")
      end

      it "returns the priority countries including the geocoded country" do
        priority_countries = helper.get_priority_countries
        expect(priority_countries).to eq(["IN"])
      end
    end

    context "when the remote IP is not geocoded to a priority country" do
      before do
        allow(mock_geocoder_result).to receive(:country).and_return("US")
      end

      it "returns the default priority countries" do
        priority_countries = helper.get_priority_countries
        expect(priority_countries).to eq(%w[US IN])
      end
    end

    context "when the geocoded country is nil" do
      before do
        allow(mock_geocoder_result).to receive(:country).and_return(nil)
      end

      it "returns the default priority countries" do
        priority_countries = helper.get_priority_countries
        expect(priority_countries).to eq(["IN"])
      end
    end
  end

  describe "#user_profile_picture" do
    it "returns the URL for the attachment if it is attached" do
      user = FactoryBot.create(:user)
      user.profile_picture.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/profile.png")),
        filename: "profile.png",
        content_type: "image/png"
      )

      expect(helper.user_profile_picture(user.profile_picture)).to eq(url_for(user.profile_picture))
    end

    it "returns the path for the default image if the attachment is not attached" do
      user1 = FactoryBot.create(:user)

      expect(helper.user_profile_picture(user1.profile_picture)).to start_with("/assets/thumb/Default-")
    end
  end

  describe "#project_image_preview" do
    it "returns the URL for the attachment if it is attached" do
      project = FactoryBot.create(:project)

      expect(helper.project_image_preview(project.image_preview)).to eq(url_for(project.image_preview))
    end

    it "returns the path for the default image if the attachment is not attached" do
      project = FactoryBot.create(:project)
      project.image_preview.purge

      expect(helper.project_image_preview(project.image_preview)).to start_with("/assets/empty_project/default-")
    end
  end
end
