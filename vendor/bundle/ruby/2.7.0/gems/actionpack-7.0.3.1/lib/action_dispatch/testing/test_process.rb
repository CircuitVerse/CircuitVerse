# frozen_string_literal: true

require "action_dispatch/middleware/cookies"
require "action_dispatch/middleware/flash"

module ActionDispatch
  module TestProcess
    module FixtureFile
      # Shortcut for <tt>Rack::Test::UploadedFile.new(File.join(ActionDispatch::IntegrationTest.file_fixture_path, path), type)</tt>:
      #
      #   post :change_avatar, params: { avatar: fixture_file_upload('david.png', 'image/png') }
      #
      # Default fixture files location is <tt>test/fixtures/files</tt>.
      #
      # To upload binary files on Windows, pass <tt>:binary</tt> as the last parameter.
      # This will not affect other platforms:
      #
      #   post :change_avatar, params: { avatar: fixture_file_upload('david.png', 'image/png', :binary) }
      def fixture_file_upload(path, mime_type = nil, binary = false)
        if self.class.file_fixture_path && !File.exist?(path)
          path = file_fixture(path)
        end

        Rack::Test::UploadedFile.new(path, mime_type, binary)
      end
    end

    include FixtureFile

    def assigns(key = nil)
      raise NoMethodError,
        "assigns has been extracted to a gem. To continue using it,
        add `gem 'rails-controller-testing'` to your Gemfile."
    end

    def session
      @request.session
    end

    def flash
      @request.flash
    end

    def cookies
      @cookie_jar ||= Cookies::CookieJar.build(@request, @request.cookies)
    end

    def redirect_to_url
      @response.redirect_url
    end
  end
end
