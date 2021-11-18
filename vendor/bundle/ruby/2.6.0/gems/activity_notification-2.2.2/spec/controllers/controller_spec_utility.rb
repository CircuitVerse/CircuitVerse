module ActivityNotification
  module ControllerSpec
    module RequestUtility
      def get_with_compatibility action, params, session
        get action, params: params, session: session
      end

      def post_with_compatibility action, params, session
        post action, params: params, session: session
      end

      def put_with_compatibility action, params, session
        put action, params: params, session: session
      end

      def delete_with_compatibility action, params, session
        delete action, params: params, session: session
      end

      def xhr_with_compatibility method, action, params, session
        send method.to_s, action, xhr: true, params: params, session: session
      end
    end

    module ApiResponseUtility
      def response_json
        JSON.parse(response.body)
      end

      def assert_json_with_array_size(json_array, size)
        expect(json_array.size).to eq(size)
      end

      def assert_json_with_object(json_object, object)
        expect(json_object['id'].to_s).to eq(object.id.to_s)
      end

      def assert_json_with_object_array(json_array, expected_object_array)
        assert_json_with_array_size(json_array, expected_object_array.size)
        expected_object_array.each_with_index do |json_object, index|
          assert_json_with_object(json_object, expected_object_array[index])
        end
      end

      def assert_error_response(code)
        expect(response_json['gem']).to eq('activity_notification')
        expect(response_json['error']['code']).to eq(code)
      end
    end

    module CommitteeUtility
      extend ActiveSupport::Concern
      included do
        include Committee::Rails::Test::Methods

        def api_path
          "/#{root_path}/#{target_type}/#{test_target.id}"
        end

        def schema_path
          Rails.root.join('..', 'openapi.json')
        end

        def write_schema_file(schema_json)
          File.open(schema_path, "w") { |file| file.write(schema_json) }
        end

        def read_schema_file
          JSON.parse(File.read(schema_path))
        end

        def committee_options
          @committee_options ||= { schema: Committee::Drivers::load_from_file(schema_path), prefix: root_path, validate_success_only: true, parse_response_by_content_type: false }
        end

        def get_with_compatibility path, options = {}
          get path, **options
        end

        def post_with_compatibility path, options = {}
          post path, **options
        end

        def put_with_compatibility path, options = {}
          put path, **options
        end

        def delete_with_compatibility path, options = {}
          delete path, **options
        end

        def assert_all_schema_confirm(response, status)
          expect(response).to have_http_status(status)
          assert_request_schema_confirm
          assert_response_schema_confirm
        end
      end
    end
  end
end
