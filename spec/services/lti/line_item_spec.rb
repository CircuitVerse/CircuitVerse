# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::LineItem do
  let(:lineitems_url) { "https://canvas.example.com/api/lti/courses/1/line_items" }
  let(:token)         { "tok-1" }
  let(:item_url)      { "#{lineitems_url}/42" }
  let(:requests)      { [] }

  def stub_http(get_body:, post_body: { id: item_url }, get_ok: true, post_ok: true, get_status: 200)
    client = instance_double(HTTP::Client)
    allow(HTTP).to receive(:timeout).and_return(client)
    allow(client).to receive_messages(auth: client, headers: client)

    allow(client).to receive(:get) do |url, options|
      requests << [:get, url, options]
      response(get_body, get_ok, get_status)
    end
    allow(client).to receive(:post) do |url, options|
      requests << [:post, url, options]
      response(post_body, post_ok, 201)
    end
    client
  end

  def response(body, success, status)
    instance_double(HTTP::Response, body: body.to_json,
                                    status: instance_double(HTTP::Response::Status,
                                                            success?: success, to_s: status.to_s))
  end

  def find_or_create
    described_class.find_or_create(lineitems_url, token,
                                   resource_id: "assignment-7", label: "Half Adder",
                                   score_maximum: 10)
  end

  describe ".find_or_create" do
    context "when the platform already holds a line item for the resource" do
      it "returns the existing column and creates nothing" do
        client = stub_http(get_body: [{ id: item_url, label: "Half Adder" }])

        expect(find_or_create).to eq(item_url)
        expect(client).not_to have_received(:post)
      end

      it "filters the lookup by resource_id" do
        stub_http(get_body: [{ id: item_url }])
        find_or_create

        expect(requests.first).to match([:get, lineitems_url, hash_including(
          params: { resource_id: "assignment-7" }
        )])
      end
    end

    context "when the platform holds no line item yet" do
      it "creates one and returns its url" do
        stub_http(get_body: [])
        expect(find_or_create).to eq(item_url)
      end

      it "posts the label, maximum score and resource id" do
        stub_http(get_body: [])
        find_or_create

        posted = JSON.parse(requests.last[2][:body])
        expect(posted).to eq("scoreMaximum" => 10, "label" => "Half Adder",
                             "resourceId" => "assignment-7")
      end
    end

    context "when the platform rejects the request" do
      it "raises when the lookup fails" do
        stub_http(get_body: {}, get_ok: false, get_status: 403)
        expect { find_or_create }.to raise_error(described_class::Error, /403/)
      end

      it "raises when creation fails" do
        stub_http(get_body: [], post_body: {}, post_ok: false)
        expect { find_or_create }.to raise_error(described_class::Error)
      end

      it "raises when the created line item carries no url" do
        stub_http(get_body: [], post_body: { label: "Half Adder" })
        expect { find_or_create }.to raise_error(described_class::Error)
      end

      it "raises when the created line item's url is not a string" do
        stub_http(get_body: [], post_body: { id: { href: item_url } })
        expect { find_or_create }.to raise_error(described_class::Error, /no id/)
      end

      it "raises rather than duplicating the column when an existing item has no id" do
        client = stub_http(get_body: [{ label: "Half Adder" }])

        expect { find_or_create }.to raise_error(described_class::Error, /no id/)
        expect(client).not_to have_received(:post)
      end

      it "raises rather than duplicating the column when an existing id is blank" do
        client = stub_http(get_body: [{ id: "" }])

        expect { find_or_create }.to raise_error(described_class::Error, /no id/)
        expect(client).not_to have_received(:post)
      end

      it "raises when the container is not a list" do
        client = stub_http(get_body: { id: item_url })

        expect { find_or_create }.to raise_error(described_class::Error, /not a list/)
        expect(client).not_to have_received(:post)
      end

      it "raises when the response is not json" do
        html = instance_double(HTTP::Response, body: "<html>",
                                               status: instance_double(HTTP::Response::Status,
                                                                       success?: true))
        client = instance_double(HTTP::Client)
        allow(HTTP).to receive(:timeout).and_return(client)
        allow(client).to receive_messages(auth: client, headers: client, get: html)

        expect { find_or_create }.to raise_error(described_class::Error)
      end

      it "raises when the platform is unreachable" do
        client = instance_double(HTTP::Client)
        allow(HTTP).to receive(:timeout).and_return(client)
        allow(client).to receive_messages(auth: client, headers: client)
        allow(client).to receive(:get).and_raise(HTTP::ConnectionError, "connection refused")

        expect { find_or_create }.to raise_error(described_class::Error, /refused/)
      end
    end
  end
end
