# frozen_string_literal: true

module CollaborationsHelper
    def auto_link_text(text)
        Rinku.auto_link(text, :all, target: '_blank', rel: 'noopener noreferrer').html_safe
    end
end
