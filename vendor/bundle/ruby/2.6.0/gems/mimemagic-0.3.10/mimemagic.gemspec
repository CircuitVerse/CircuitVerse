# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/lib/mimemagic/version'
require 'date'

Gem::Specification.new do |s|
  s.name = 'mimemagic'
  s.version = MimeMagic::VERSION

  s.authors = ['Daniel Mendler', 'Jon Wood']
  s.date = Date.today.to_s
  s.email = ['mail@daniel-mendler.de', 'jon@blankpad.net']

  s.files         = `git ls-files`.split("\n").reject { |f| f.match(%r{^(test|script)/}) }
  s.require_paths = %w(lib)
  s.extensions = %w(ext/mimemagic/Rakefile)

  s.summary = 'Fast mime detection by extension or content'
  s.description = 'Fast mime detection by extension or content (Uses freedesktop.org.xml shared-mime-info database)'
  s.homepage = 'https://github.com/mimemagicrb/mimemagic'
  s.license = 'MIT'

  s.add_dependency('nokogiri', '~> 1')
  s.add_dependency('rake')

  s.add_development_dependency('minitest', '~> 5.14')

  if s.respond_to?(:metadata)
    s.metadata['changelog_uri'] = "https://github.com/mimemagicrb/mimemagic/blob/master/CHANGELOG.md"
    s.metadata['source_code_uri'] = "https://github.com/mimemagicrb/mimemagic"
    s.metadata['bug_tracker_uri'] = "https://github.com/mimemagicrb/mimemagic/issues"
  end
end
