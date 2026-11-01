# frozen_string_literal: true

require "rails_helper"

describe SearchHelper do
  include described_class

  let(:query_params) do
    {
      resource: @resource,
      q: "dummy query"
    }
  end

  describe "#query" do
    context "resource is Users" do
      it "returns correct template" do
        @resource = "Users"
        _, template = query(@resource, query_params)

        expect(template).to eq("/users/circuitverse/search")
      end
    end

    context "resource if Projects" do
      it "returns correct template" do
        @resource = "Projects"
        _, template = query(@resource, query_params)

        expect(template).to eq("/projects/search")
      end
    end
  end

  describe "#get_user_country_code_simple" do
    let(:request) { instance_double(ActionDispatch::Request) }

    it "returns nil when request is nil" do
      expect(helper.send(:get_user_country_code_simple, nil)).to be_nil
    end

    it "returns nil for IPv4 loopback address" do
      allow(request).to receive(:remote_ip).and_return("127.0.0.1")
      expect(helper.send(:get_user_country_code_simple, request)).to be_nil
    end

    it "returns nil for IPv6 loopback address" do
      allow(request).to receive(:remote_ip).and_return("::1")
      expect(helper.send(:get_user_country_code_simple, request)).to be_nil
    end

    it "returns country code for public IP addresses" do
      allow(request).to receive(:remote_ip).and_return("8.8.8.8")
      expect(helper.send(:get_user_country_code_simple, request)).to eq("US")
    end

    it "safely returns nil when Geocoder encounters a system or network error" do
      allow(request).to receive(:remote_ip).and_return("8.8.8.8")
      allow(Geocoder).to receive(:search).and_raise(Errno::EMFILE, "Too many open files - pipe(2)")

      expect { helper.send(:get_user_country_code_simple, request) }.not_to raise_error
      expect(helper.send(:get_user_country_code_simple, request)).to be_nil
    end
  end
end
