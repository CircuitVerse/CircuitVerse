# frozen_string_literal: true

steep_diagnostic = Steep::Diagnostic

target :app do
  check "app/models"
  signature "sig"
  configure_code_diagnostics(steep_diagnostic::Ruby.lenient)
  configure_code_diagnostics do |hash|
    hash[steep_diagnostic::Ruby::NoMethod] = :information
  end
end
