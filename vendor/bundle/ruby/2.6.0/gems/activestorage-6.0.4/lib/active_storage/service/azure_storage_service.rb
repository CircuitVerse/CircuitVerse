# frozen_string_literal: true

require "active_support/core_ext/numeric/bytes"
require "azure/storage"
require "azure/storage/core/auth/shared_access_signature"

module ActiveStorage
  # Wraps the Microsoft Azure Storage Blob Service as an Active Storage service.
  # See ActiveStorage::Service for the generic API documentation that applies to all services.
  class Service::AzureStorageService < Service
    attr_reader :client, :blobs, :container, :signer

    def initialize(storage_account_name:, storage_access_key:, container:, **options)
      @client = Azure::Storage::Client.create(storage_account_name: storage_account_name, storage_access_key: storage_access_key, **options)
      @signer = Azure::Storage::Core::Auth::SharedAccessSignature.new(storage_account_name, storage_access_key)
      @blobs = client.blob_client
      @container = container
    end

    def upload(key, io, checksum: nil, **)
      instrument :upload, key: key, checksum: checksum do
        handle_errors do
          blobs.create_block_blob(container, key, IO.try_convert(io) || io, content_md5: checksum)
        end
      end
    end

    def download(key, &block)
      if block_given?
        instrument :streaming_download, key: key do
          stream(key, &block)
        end
      else
        instrument :download, key: key do
          handle_errors do
            _, io = blobs.get_blob(container, key)
            io.force_encoding(Encoding::BINARY)
          end
        end
      end
    end

    def download_chunk(key, range)
      instrument :download_chunk, key: key, range: range do
        handle_errors do
          _, io = blobs.get_blob(container, key, start_range: range.begin, end_range: range.exclude_end? ? range.end - 1 : range.end)
          io.force_encoding(Encoding::BINARY)
        end
      end
    end

    def delete(key)
      instrument :delete, key: key do
        blobs.delete_blob(container, key)
      rescue Azure::Core::Http::HTTPError => e
        raise unless e.type == "BlobNotFound"
        # Ignore files already deleted
      end
    end

    def delete_prefixed(prefix)
      instrument :delete_prefixed, prefix: prefix do
        marker = nil

        loop do
          results = blobs.list_blobs(container, prefix: prefix, marker: marker)

          results.each do |blob|
            blobs.delete_blob(container, blob.name)
          end

          break unless marker = results.continuation_token.presence
        end
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        answer = blob_for(key).present?
        payload[:exist] = answer
        answer
      end
    end

    def url(key, expires_in:, filename:, disposition:, content_type:)
      instrument :url, key: key do |payload|
        generated_url = signer.signed_uri(
          uri_for(key), false,
          service: "b",
          permissions: "r",
          expiry: format_expiry(expires_in),
          content_disposition: content_disposition_with(type: disposition, filename: filename),
          content_type: content_type
        ).to_s

        payload[:url] = generated_url

        generated_url
      end
    end

    def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
      instrument :url, key: key do |payload|
        generated_url = signer.signed_uri(
          uri_for(key), false,
          service: "b",
          permissions: "rw",
          expiry: format_expiry(expires_in)
        ).to_s

        payload[:url] = generated_url

        generated_url
      end
    end

    def headers_for_direct_upload(key, content_type:, checksum:, **)
      { "Content-Type" => content_type, "Content-MD5" => checksum, "x-ms-blob-type" => "BlockBlob" }
    end

    private
      def uri_for(key)
        blobs.generate_uri("#{container}/#{key}")
      end

      def blob_for(key)
        blobs.get_blob_properties(container, key)
      rescue Azure::Core::Http::HTTPError
        false
      end

      def format_expiry(expires_in)
        expires_in ? Time.now.utc.advance(seconds: expires_in).iso8601 : nil
      end

      # Reads the object for the given key in chunks, yielding each to the block.
      def stream(key)
        blob = blob_for(key)

        chunk_size = 5.megabytes
        offset = 0

        raise ActiveStorage::FileNotFoundError unless blob.present?

        while offset < blob.properties[:content_length]
          _, chunk = blobs.get_blob(container, key, start_range: offset, end_range: offset + chunk_size - 1)
          yield chunk.force_encoding(Encoding::BINARY)
          offset += chunk_size
        end
      end

      def handle_errors
        yield
      rescue Azure::Core::Http::HTTPError => e
        case e.type
        when "BlobNotFound"
          raise ActiveStorage::FileNotFoundError
        when "Md5Mismatch"
          raise ActiveStorage::IntegrityError
        else
          raise
        end
      end
  end
end
