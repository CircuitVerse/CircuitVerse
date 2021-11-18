require_relative '../spec_helper'

describe DeviceDetector do
  fixture_dir = File.expand_path('../fixtures/detector', __dir__)
  fixture_files = Dir["#{fixture_dir}/*.yml"]
  fixture_files.each do |fixture_file|
    describe File.basename(fixture_file) do
      fixtures = nil
      begin
        fixtures = YAML.load(File.read(fixture_file))
      rescue Psych::SyntaxError => e
        raise "Failed to parse #{fixture_file}, reason: #{e}"
      end

      def str_or_nil(string)
        return nil if string.nil?
        return nil if string == ''

        string.to_s
      end

      fixtures.each do |f|
        user_agent = f['user_agent']
        detector = DeviceDetector.new(user_agent)
        os = detector.send(:os)

        describe user_agent do
          it 'should be detected' do
            if detector.bot?
              assert_equal str_or_nil(f['bot']['name']), detector.bot_name, 'failed bot name detection'
            else
              if f['client']
                assert_equal str_or_nil(f['client']['name']), detector.name, 'failed client name detection'
              end

              os_family = str_or_nil(f['os_family'])
              if os_family != 'Unknown'
                if os_family.nil?
                  assert_nil os.family, 'failed os family detection'
                else
                  assert_equal os_family, os.family, 'failed os family detection'
                end

                name = str_or_nil(f['os']['name'])
                if name.nil?
                  assert_nil os.name, 'failed os name detection'
                else
                  assert_equal name, os.name, 'failed os name detection'
                end

                short_name = str_or_nil(f['os']['short_name'])
                if short_name.nil?
                  assert_nil os.short_name, 'failed os short name detection'
                else
                  assert_equal short_name, os.short_name, 'failed os short name detection'
                end

                os_version = str_or_nil(f['os']['version'])
                if os_version.nil?
                  assert_nil os.full_version, 'failed os version detection'
                else
                  assert_equal os_version, os.full_version, 'failed os version detection'
                end
              end
              if f['device']
                expected_type = str_or_nil(f['device']['type'])
                actual_type = detector.device_type

                if expected_type != actual_type
                  # puts "\n", f.inspect, expected_type, actual_type, detector.device_name, regex_meta.inspect
                  # debugger
                  # detector.device_type
                end
                if expected_type.nil?
                  assert_nil actual_type, 'failed device type detection'
                else
                  assert_equal expected_type, actual_type, 'failed device type detection'
                end

                model = str_or_nil(f['device']['model'])
                model = model.to_s unless model.nil?

                if model.nil?
                  assert_nil detector.device_name, 'failed device name detection'
                else
                  assert_equal model, detector.device_name, 'failed device name detection'
                end
              end
            end
          end
        end
      end
    end
  end
end
