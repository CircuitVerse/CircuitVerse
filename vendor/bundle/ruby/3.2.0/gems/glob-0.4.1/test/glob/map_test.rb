# frozen_string_literal: true

require "test_helper"

class MapTest < Minitest::Test
  test "generates map for hash" do
    map = Glob::Map.call(
      user: {
        email: "EMAIL",
        addresses: [
          {
            description: "DESCRIPTION",
            city: "CITY",
            state: "STATE"
          }
        ],
        preferences: {
          theme: "dark"
        }
      },

      options: {
        notifications: {
          system: true,
          marketing: true
        }
      }
    )

    assert_equal [
      "options.notifications.marketing",
      "options.notifications.system",
      "user.addresses",
      "user.email",
      "user.preferences.theme"
    ], map
  end
end
