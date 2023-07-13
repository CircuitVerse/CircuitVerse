# frozen_string_literal: true

steep_diagnostic = Steep::Diagnostic

target :app do
  check "app/models"
  check "app/decorators"
  check "app/notifications"
  check "app/helpers"
  check "app/policies"
  ignore "app/policies/user_policy.rb"

  signature "sig"

  configure_code_diagnostics(steep_diagnostic::Ruby.lenient)
  configure_code_diagnostics do |hash|
    hash[steep_diagnostic::Ruby::NoMethod] = :information
  end
end
