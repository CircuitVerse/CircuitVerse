# frozen_string_literal: true

require "rails_helper"

describe SimulatorHelper do
  include described_class

  def data_url(image_str)
    "data:image/jpeg;base64,#{image_str}"
  end

  describe "#check_to_delete" do
    it "give true for non empty images" do
      expect(check_to_delete(data_url(""))).to be false
      expect(check_to_delete(data_url(Faker::Alphanumeric.alpha(number: 20)))).to be true
    end
  end

  describe "#return_image_url" do
    context "circuit is empty" do
      it "returns default file" do
        expect(return_image_file(data_url(""))).to be_a(File)
      end

      it "returns the default image file" do
        file = return_image_file("")
        expect(file.path).to eq(Rails.public_path.join("images/default.png").to_s)
      end
    end

    context "circuit has elements" do
      let(:data_url) { "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 100)}" }
      let(:jpeg) { Base64.decode64(data_url[("data:image/jpeg;base64,".length)..]) }
      let(:image_file) { StringIO.new(jpeg) }

      before do
        allow(Base64).to receive(:decode64).and_return(jpeg)
        allow(StringIO).to receive(:new).with(jpeg).and_return(image_file)
      end

      it "creates a new File object" do
        returned_file = return_image_file(data_url)
        expect(returned_file.path).to start_with("tmp/preview_")
      end
    end
  end

  describe "#parse_image_data_url" do
    context "circuit is empty" do
      it "returns nil" do
        expect(parse_image_data_url(data_url(""))).to be_nil
      end
    end

    context "circuit has elements" do
      let(:data_url) { "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 100)}" }
      let(:jpeg) { Base64.decode64(data_url[("data:image/jpeg;base64,".length)..]) }
      let(:image_file) { StringIO.new(jpeg) }

      before do
        allow(Base64).to receive(:decode64).and_return(jpeg)
        allow(StringIO).to receive(:new).with(jpeg).and_return(image_file)
      end

      it "creates a new StringIO object" do
        expect(parse_image_data_url(data_url)).to eq(image_file)
      end
    end
  end

  describe "#sanitize_data" do
    let(:data) do
      {
        scopes: [
          {
            Element: [{ label: "label" }]
          }
        ]
      }
    end

    before do
      group = FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user))
      assignment = FactoryBot.create(:assignment, group: group, restrictions: ["Element"].to_json)
      @project = FactoryBot.create(:project,
                                   author: FactoryBot.create(:user), assignment: assignment)
    end

    it "sanitizes project data to populate restricted elements correctly" do
      sanitized_data = sanitize_data(@project, data.to_json)
      expect(JSON.parse(sanitized_data)["scopes"][0]["restrictedCircuitElementsUsed"])
        .to eq(["Element"])
    end
  end
end
