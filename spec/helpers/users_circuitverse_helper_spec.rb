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

      expect(helper.user_profile_picture(user.profile_picture)).to eq(user.profile_picture)
    end

    it "returns the path for the default image if the attachment is not attached" do
      user1 = FactoryBot.create(:user)

      expect(helper.user_profile_picture(user1.profile_picture)).to start_with("/assets/thumb/Default-")
    end
  end

  describe "#project_image_preview" do
    context "Flipper is enabled" do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project)
        @project.circuit_preview.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/default.png")),
          filename: "preview_1234.jpeg",
          content_type: "img/jpeg"
        )
      end

      it "returns ActiveStorage attachment" do
        expect(helper.project_image_preview(@project, @user)).to eq(@project.circuit_preview)
      end

      it "returns default image" do
        @project.circuit_preview.purge
        expect(helper.project_image_preview(@project, @user)).to start_with("/assets/empty_project/default-")
      end
    end

    context "Flipper is Disabled" do
      before do
        Flipper.disable(:active_storage_s3)
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project)
      end

      it "returns default image" do
        expect(helper.project_image_preview(@project, @user)).to start_with("/assets/empty_project/default-")
      end

      it "returns PaperClip url" do
        image_file = File.open(Rails.root.join("spec/fixtures/files/default.png"))
        @project.image_preview = image_file
        expect(helper.project_image_preview(@project, @user)).to eq(@project.image_preview.url)
      end
    end
  end
end
