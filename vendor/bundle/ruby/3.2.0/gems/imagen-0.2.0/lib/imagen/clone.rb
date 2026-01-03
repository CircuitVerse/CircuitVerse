# frozen_string_literal: true

require 'open3'

module Imagen
  # Generic clone error
  class GitError < StandardError; end

  # Responsible for cloning a Git repository into a given tempdir
  class Clone
    def self.perform(repo_url, dir)
      new(repo_url, dir).perform
    end

    attr_reader :repo_url, :dir

    def initialize(repo_url, dirname)
      raise ArgumentError, 'repo_url must start with https://' unless repo_url.match?(/^https:\/\//)

      @repo_url = repo_url
      @dir = dirname
    end

    def perform
      cmd = "GIT_TERMINAL_PROMPT=0 git clone #{repo_url} #{dir}"
      Open3.popen3(cmd) do |_s_in, _s_out, s_err, wait_thr|
        err_msg = s_err.read
        raise GitError, err_msg unless wait_thr.value.exitstatus.zero?
      end
    end
  end
end
