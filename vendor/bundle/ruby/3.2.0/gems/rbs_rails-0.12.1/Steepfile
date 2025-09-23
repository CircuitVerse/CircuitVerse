D = Steep::Diagnostic
target :lib do
  signature "sig"
  signature 'assets/sig'

  check "lib"                       # Directory name
  repo_path ENV['RBS_REPO_DIR'] if ENV['RBS_REPO_DIR']

  configure_code_diagnostics do |hash|
    hash[D::Ruby::UnreachableBranch] = :information
  end
end
