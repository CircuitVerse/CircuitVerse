# frozen_string_literal: true

require "tmpdir"
require "active_support/core_ext/string/filters"

module ActiveStorage
  module Downloading
    def self.included(klass)
      ActiveSupport::Deprecation.warn <<~MESSAGE.squish, caller_locations(2)
        ActiveStorage::Downloading is deprecated and will be removed in Active Storage 6.1.
        Use ActiveStorage::Blob#open instead.
      MESSAGE
    end

    private
      # Opens a new tempfile in #tempdir and copies blob data into it. Yields the tempfile.
      def download_blob_to_tempfile #:doc:
        open_tempfile_for_blob do |file|
          download_blob_to file
          yield file
        end
      end

      def open_tempfile_for_blob
        tempfile = Tempfile.open([ "ActiveStorage", blob.filename.extension_with_delimiter ], tempdir)

        begin
          yield tempfile
        ensure
          tempfile.close!
        end
      end

      # Efficiently downloads blob data into the given file.
      def download_blob_to(file) #:doc:
        file.binmode
        blob.download { |chunk| file.write(chunk) }
        file.flush
        file.rewind
      end

      # Returns the directory in which tempfiles should be opened. Defaults to +Dir.tmpdir+.
      def tempdir #:doc:
        Dir.tmpdir
      end
  end
end
