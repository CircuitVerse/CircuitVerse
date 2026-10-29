# frozen_string_literal: true

require "pagy/extras/bootstrap"
# Translate the nav through Rails I18n so it follows the request locale
require "pagy/extras/i18n"
require "pagy/extras/overflow"

Pagy::DEFAULT[:limit] = 10
Pagy::DEFAULT[:overflow] = :last_page
Pagy::DEFAULT.freeze