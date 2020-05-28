# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "CircuitVerse <noreply@circuitverse.org>"
  layout "mailer"
end
