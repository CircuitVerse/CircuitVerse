module Lookbook
  class DebugMenu::Component < Lookbook::BaseComponent
    attr_reader :features

    def initialize(version: nil, docs_url: nil, repo_url: nil, features: {}, **html_attrs)
      @version = version
      @docs_url = docs_url
      @repo_url = repo_url
      @features = features
      super(**html_attrs)
    end

    def auto_refresh_enabled?
      feature(:auto_refresh, false)
    end

    def feature(name, fallback = nil)
      features.fetch(name.to_sym, fallback)
    end

    def debug_data
      content
    end

    def debug_data?
      debug_data.present?
    end
  end
end
