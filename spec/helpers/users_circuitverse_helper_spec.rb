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
        io: Rails.root.join("spec/fixtures/files/profile.png").open,
        filename: "profile.png",
        content_type: "image/png"
      )
      expect(user.profile_picture.attached?).to be true
      expect(user_profile_picture(user.profile_picture)).to eq(user.profile_picture)
    end

    it "returns the path for the default image if the attachment is not attached" do
      user1 = FactoryBot.create(:user)
      expect(user1.profile_picture.attached?).to be false
      expect(user_profile_picture(user1.profile_picture)).to eq("/images/thumb/Default.jpg")
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
        circuit_preview = send(:return_circuit_preview, @project)
        expect(Flipper.enabled?(:active_storage_s3, @user)).to be true
        expect(circuit_preview).to eq(@project.circuit_preview)
        expect(project_image_preview(@project, @user)).to eq(@project.circuit_preview)
      end

      it "returns default image" do
        @project.circuit_preview.purge
        expect(Flipper.enabled?(:active_storage_s3, @user)).to be true
        default_image_path = send(:return_circuit_preview, @project)
        expect(default_image_path).to eq("/images/empty_project/default.png")
        expect(project_image_preview(@project, @user)).to eq("/images/empty_project/default.png")
      end
    end

    context "Flipper is Disabled" do
      before do
        Flipper.disable(:active_storage_s3)
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project)
      end

      it "returns default image" do
        @project.image_preview = nil
        expect(Flipper.enabled?(:active_storage_s3, @user)).to be false
        default_image_path = send(:return_image_preview, @project)
        expect(default_image_path).to eq("/images/empty_project/default.png")
        expect(project_image_preview(@project, @user)).to eq("/images/empty_project/default.png")
      end

      it "returns PaperClip url" do
        image_file = File.open(Rails.root.join("spec/fixtures/files/default.png"))
        @project.image_preview = image_file
        expect(Flipper.enabled?(:active_storage_s3, @user)).to be false
        image_preview_url = send(:return_image_preview, @project)
        expect(image_preview_url).to eq(@project.image_preview.url)
        expect(project_image_preview(@project, @user)).to eq(@project.image_preview.url)
      end
    end
  end
end
