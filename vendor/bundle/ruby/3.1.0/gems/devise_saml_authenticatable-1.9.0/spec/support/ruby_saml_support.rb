module RubySamlSupport
  VERSION_1_12 = Gem::Version.new("1.12.0")
  def with_ruby_saml_1_12_or_greater(body, args = {else_do: nil})
    if Gem::Version.new(OneLogin::RubySaml::VERSION) >= VERSION_1_12
      body.call
    else
      args[:else_do].call
    end
  end
end
