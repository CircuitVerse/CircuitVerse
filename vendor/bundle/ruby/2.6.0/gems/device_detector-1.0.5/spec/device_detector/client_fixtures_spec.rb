require_relative '../spec_helper'

describe DeviceDetector::Client do

  fixture_dir = File.expand_path('../../fixtures/client', __FILE__)
  fixture_files = Dir["#{fixture_dir}/*.yml"]
  fixture_files.each do |fixture_file|

    describe File.basename(fixture_file) do

      fixtures = YAML.load_file(fixture_file)
      fixtures.each do |f|

        user_agent = f["user_agent"]
        client = DeviceDetector::Client.new(user_agent)

        describe user_agent do

          it "should be known" do
            assert client.known?, "isn't known as a client"
          end

          it "should have the expected name" do
            assert_equal f["client"]["name"], client.name, "failed client name detection"
          end

        end
      end
    end
  end
end
