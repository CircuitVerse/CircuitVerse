# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests#show queries", type: :request do
  it "eager loads project authors for submission cards" do
    contest = create(:contest, :live)
    viewer  = create(:user)

    create_list(:submission, 3, contest: contest)

    sign_in viewer

    users_queries = []
    callback = lambda do |_name, _start, _finish, _id, payload|
      sql = payload[:sql]
      next unless sql.match?(/SELECT .*"users"/)
      next if payload[:name].in?(%w[SCHEMA TRANSACTION])

      users_queries << sql
    end
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record", &callback)

    begin
      get contest_path(contest)
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end

    expect(response).to have_http_status(:ok)
    expect(users_queries.grep(/WHERE "users"\."id" =/).size).to be <= 1
  end
end
