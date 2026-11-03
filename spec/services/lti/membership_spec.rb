# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::Membership do
  let(:url)   { "https://canvas.example.com/api/lti/courses/1/names_and_roles" }
  let(:token) { "tok-1" }
  let(:requested) { [] }

  def member(id, roles: [described_class::LEARNER], status: "Active")
    { "user_id" => id, "roles" => roles, "status" => status,
      "name" => "User #{id}", "email" => "#{id}@example.com" }
  end

  def page(members, next_url: nil, success: true, status: 200, body: nil)
    headers = next_url ? { "Link" => %(<#{next_url}>; rel="next") } : {}
    instance_double(HTTP::Response,
                    body: (body || { "members" => members }).to_json,
                    headers: headers,
                    status: instance_double(HTTP::Response::Status,
                                            success?: success, to_s: status.to_s))
  end

  def stub_pages(*pages)
    client = instance_double(HTTP::Client)
    allow(HTTP).to receive(:timeout).and_return(client)
    allow(client).to receive_messages(auth: client, headers: client)
    allow(client).to receive(:get) do |requested_url|
      requested << requested_url
      pages[requested.size - 1] || pages.last
    end
    client
  end

  describe ".fetch" do
    it "returns the members the platform reports" do
      stub_pages(page([member("u1"), member("u2")]))

      expect(described_class.fetch(url, token).pluck("user_id")).to eq(%w[u1 u2])
    end

    it "keeps roles and status so the caller can tell learners from staff" do
      stub_pages(page([member("u1", roles: [described_class::INSTRUCTOR], status: "Inactive")]))

      expect(described_class.fetch(url, token).first)
        .to include("roles" => [described_class::INSTRUCTOR], "status" => "Inactive")
    end

    it "follows the next link until the platform stops sending one" do
      stub_pages(page([member("u1")], next_url: "#{url}?page=2"),
                 page([member("u2")], next_url: "#{url}?page=3"),
                 page([member("u3")]))

      expect(described_class.fetch(url, token).pluck("user_id")).to eq(%w[u1 u2 u3])
      expect(requested).to eq([url, "#{url}?page=2", "#{url}?page=3"])
    end

    it "raises rather than returning a partial roster when a platform never stops paginating" do
      stub_pages(page([member("u1")], next_url: url))

      expect { described_class.fetch(url, token) }
        .to raise_error(described_class::Error, /did not end within/)
    end

    it "follows a next link given as a bare token relation" do
      first = page([member("u1")])
      allow(first).to receive(:headers).and_return({ "Link" => "<#{url}?page=2>; rel=next" })
      stub_pages(first, page([member("u2")]))

      expect(described_class.fetch(url, token).pluck("user_id")).to eq(%w[u1 u2])
    end

    it "finds the next link among other relations and parameters" do
      first = page([member("u1")])
      allow(first).to receive(:headers).and_return(
        { "Link" => %(<#{url}?page=1>; rel="first", <#{url}?page=2>; type="application/json"; rel="next") }
      )
      stub_pages(first, page([member("u2")]))
      described_class.fetch(url, token)

      expect(requested.last).to eq("#{url}?page=2")
    end

    it "finds the next link when another parameter contains a comma" do
      first = page([member("u1")])
      allow(first).to receive(:headers).and_return(
        { "Link" => %(<#{url}?page=2>; title="page, two"; rel="next") }
      )
      stub_pages(first, page([member("u2")]))
      described_class.fetch(url, token)

      expect(requested.last).to eq("#{url}?page=2")
    end

    it "refuses to carry the token to a next link on another origin" do
      first = page([member("u1")])
      allow(first).to receive(:headers).and_return(
        { "Link" => %(<https://attacker.example.com/roster>; rel="next") }
      )
      stub_pages(first, page([member("u2")]))

      expect { described_class.fetch(url, token) }
        .to raise_error(described_class::Error, /left the platform origin/)
      expect(requested).to eq([url])
    end

    it "raises rather than ending the roster on a next link it cannot resolve" do
      first = page([member("u1")])
      allow(first).to receive(:headers).and_return({ "Link" => %(<http://exa mple.com/%%>; rel="next") })
      stub_pages(first, page([member("u2")]))

      expect { described_class.fetch(url, token) }
        .to raise_error(described_class::Error, /could not be resolved/)
    end

    it "resolves a relative next link against the page it came from" do
      first = page([member("u1")])
      allow(first).to receive(:headers).and_return({ "Link" => %(</api/lti/courses/1/nrps?page=2>; rel="next") })
      stub_pages(first, page([member("u2")]))
      described_class.fetch(url, token)

      expect(requested.last).to eq("https://canvas.example.com/api/lti/courses/1/nrps?page=2")
    end

    it "sends the bearer token and the nrps media type" do
      client = stub_pages(page([]))
      described_class.fetch(url, token)

      expect(client).to have_received(:auth).with("Bearer tok-1")
      expect(client).to have_received(:headers).with("Accept" => described_class::MEDIA_TYPE)
    end

    it "reads an empty roster as no members" do
      stub_pages(page([]))

      expect(described_class.fetch(url, token)).to eq([])
    end

    it "raises rather than reading a page with no members list as an empty class" do
      stub_pages(page(nil, body: { "id" => url }))

      expect { described_class.fetch(url, token) }
        .to raise_error(described_class::Error, /no members list/)
    end

    it "raises when the page is not an object" do
      stub_pages(page(nil, body: [{ "user_id" => "u1" }]))

      expect { described_class.fetch(url, token) }
        .to raise_error(described_class::Error, /no members list/)
    end

    it "raises when the platform refuses the request" do
      stub_pages(page([], success: false, status: 403))

      expect { described_class.fetch(url, token) }.to raise_error(described_class::Error, /403/)
    end

    it "raises when the response is not json" do
      client = instance_double(HTTP::Client)
      allow(HTTP).to receive(:timeout).and_return(client)
      allow(client).to receive_messages(auth: client, headers: client,
                                        get: instance_double(HTTP::Response, body: "<html>",
                                                                             headers: {},
                                                                             status: instance_double(
                                                                               HTTP::Response::Status, success?: true
                                                                             )))

      expect { described_class.fetch(url, token) }.to raise_error(described_class::Error)
    end

    it "raises when the platform is unreachable" do
      client = instance_double(HTTP::Client)
      allow(HTTP).to receive(:timeout).and_return(client)
      allow(client).to receive_messages(auth: client, headers: client)
      allow(client).to receive(:get).and_raise(HTTP::ConnectionError, "connection refused")

      expect { described_class.fetch(url, token) }.to raise_error(described_class::Error, /refused/)
    end
  end
end
