# frozen_string_literal: true

require 'parser/current'
require 'tmpdir'

module Imagen
  # RemoteBuilder is responsible for wrapping all operations to create code
  # structure for a remote git repository.
  class RemoteBuilder
    attr_reader :repo_url, :dir

    def initialize(repo_url)
      @repo_url = repo_url
      @dir = Dir.mktmpdir
    end

    def build
      Clone.perform(repo_url, dir)
      Imagen::Node::Root.new.build_from_dir(dir).tap { teardown }
    end

    private

    def teardown
      FileUtils.remove_entry dir
    end
  end
end
