# -*- encoding: utf-8 -*-
# stub: kt-paperclip 7.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "kt-paperclip".freeze
  s.version = "7.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Surendra Singhi".freeze]
  s.date = "2024-01-19"
  s.description = "Easy upload management for ActiveRecord".freeze
  s.email = ["ssinghi@kreeti.com".freeze]
  s.homepage = "https://github.com/kreeti/kt-paperclip".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "##################################################\n#  NOTE FOR UPGRADING FROM 4.3.0 OR EARLIER      #\n##################################################\n\nPaperclip is now compatible with aws-sdk-s3.\n\nIf you are using S3 storage, aws-sdk-s3 requires you to make a few small\nchanges:\n\n* You must set the `s3_region`\n* If you are explicitly setting permissions anywhere, such as in an initializer,\n  note that the format of the permissions changed from using an underscore to\n  using a hyphen. For example, `:public_read` needs to be changed to\n  `public-read`.\n\nFor a walkthrough of upgrading from 4 to *5* (not 6) and aws-sdk >= 2.0 you can watch\nhttp://rubythursday.com/episodes/ruby-snack-27-upgrade-paperclip-and-aws-sdk-in-prep-for-rails-5\n".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.requirements = ["ImageMagick".freeze]
  s.rubygems_version = "3.4.6".freeze
  s.summary = "File attachments as attributes for ActiveRecord".freeze

  s.installed_by_version = "3.4.6" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activemodel>.freeze, [">= 4.2.0"])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.2.0"])
  s.add_runtime_dependency(%q<mime-types>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<marcel>.freeze, ["~> 1.0.1"])
  s.add_runtime_dependency(%q<terrapin>.freeze, [">= 0.6.0", "< 2.0"])
  s.add_development_dependency(%q<activerecord>.freeze, [">= 4.2.0"])
  s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
  s.add_development_dependency(%q<aruba>.freeze, ["~> 0.9.0"])
  s.add_development_dependency(%q<aws-sdk-s3>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
  s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
  s.add_development_dependency(%q<cucumber-expressions>.freeze, [">= 0"])
  s.add_development_dependency(%q<cucumber-rails>.freeze, [">= 0"])
  s.add_development_dependency(%q<fakeweb>.freeze, [">= 0"])
  s.add_development_dependency(%q<fog-aws>.freeze, [">= 0"])
  s.add_development_dependency(%q<fog-local>.freeze, [">= 0"])
  s.add_development_dependency(%q<generator_spec>.freeze, [">= 0"])
  s.add_development_dependency(%q<launchy>.freeze, [">= 0"])
  s.add_development_dependency(%q<nokogiri>.freeze, [">= 0"])
  s.add_development_dependency(%q<railties>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<shoulda>.freeze, [">= 0"])
  s.add_development_dependency(%q<timecop>.freeze, [">= 0"])
end
