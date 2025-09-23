# -*- encoding: utf-8 -*-
# stub: friendly_id 5.5.1 ruby lib

Gem::Specification.new do |s|
  s.name = "friendly_id".freeze
  s.version = "5.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Norman Clarke".freeze, "Philip Arndt".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIEljCCAv6gAwIBAgIBATANBgkqhkiG9w0BAQsFADBRMREwDwYDVQQDDAhydWJ5\nZ2VtczERMA8GCgmSJomT8ixkARkWAXAxFTATBgoJkiaJk/IsZAEZFgVhcm5kdDES\nMBAGCgmSJomT8ixkARkWAmlvMB4XDTIyMTExNTIyMjQzMFoXDTIzMTExNTIyMjQz\nMFowUTERMA8GA1UEAwwIcnVieWdlbXMxETAPBgoJkiaJk/IsZAEZFgFwMRUwEwYK\nCZImiZPyLGQBGRYFYXJuZHQxEjAQBgoJkiaJk/IsZAEZFgJpbzCCAaIwDQYJKoZI\nhvcNAQEBBQADggGPADCCAYoCggGBAMPq2bIEO+BmmBeuidSySK7xlL/LWBHzyDxw\nEMgWsHqJMDZYCZI4WoWbSTSSLrp5zPXLWN0hB23u3dxFp4RVygTTZkc8k05mteab\nfdREGgdcP+mY8/ASQSvb1VW6IM51Srgjy1SK0S5Qf3HAiQafFvRsxRkY0SWyth24\nne/7HG667vHQ1+t0VFl8twupJE9S8p2zgX3eZBl2yRNm/kE5reUsOLvmS58Iri/X\n9tnz0SGkzrKkim9OIByq7XkFLL3oaIyfbBVgOWilM5pvxj/xNuRH7EIM6aE3q0UZ\nxo7o9u9Iz2zApDEjejByPjxWAhLuP3v3bJyinRFE1rO47lEM/s6KM/6YooxvgYIN\nmiYYFRtTj9nmKEMv6+h1mZ1/ZwqStTTRh/T90T65dcgsoqRd0JNvpNRjFrYH5cuj\nQZWMl/FE6AADm0GXa34ZiTQx3Wx2ctqJLFak8+imPwes90nCpiYmgaZpwBI+shjU\nAddbPDNq+EoxPMWTh0Er3w76fywOWQIDAQABo3kwdzAJBgNVHRMEAjAAMAsGA1Ud\nDwQEAwIEsDAdBgNVHQ4EFgQUxRJaTQZmtkN8FKUWVHKc2riND18wHgYDVR0RBBcw\nFYETcnVieWdlbXNAcC5hcm5kdC5pbzAeBgNVHRIEFzAVgRNydWJ5Z2Vtc0BwLmFy\nbmR0LmlvMA0GCSqGSIb3DQEBCwUAA4IBgQBSRGMkZ2dvJ0LSjFz+rIt3G3AZMbKD\ntjaaQRuC9rOkrl3Rml6h9j7cHYiM0wkTjXneFNySc8jWmM/jKnxiiUfUK9r1XL4n\n71tz39+MD2lIpLVVEQ69MIoUseppNUTCg0mNghSDYNwISMD/hoWwbJudBi56DbhE\nxkulLbw8qtcEE+iilIKibe+eJF4platKScsOA7d1AuilR1/S245UzeqwwyI52/xK\ndfoP928X9Tb/48+83lWUgAgCQOd6WdfCpgQ5H6R90lc8L7OfuDR/vgcmSOTsNVgG\n1TC3b2FISS0p0qfZsiS7BXh+ARoBKLXsV1a7WR36X0dUpajvk+zzBGrFCdbW43Gx\nwmJzIksYnf9Ktg8Ux+FLcRBGw4qEIyWvqmS0obB1Hke68rTg0uNTFcKXsNw33XF5\nfw1cbj95g7OPe0feGK8+afXh/L38vx/hIIOGlUEZ+HaWL2Dki/7vRGvda8dfOpG5\nbJfaoyKbVsrK+gGKFJv860zsO8lg6BGLsUw=\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2023-11-12"
  s.description = "FriendlyId is the \"Swiss Army bulldozer\" of slugging and permalink plugins for Active Record. It lets you create pretty URLs and work with human-friendly strings as if they were numeric ids.".freeze
  s.email = ["norman@njclarke.com".freeze, "p@arndt.io".freeze]
  s.homepage = "https://github.com/norman/friendly_id".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "A comprehensive slugging and pretty-URL plugin.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4.0.0"])
  s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
  s.add_development_dependency(%q<railties>.freeze, [">= 4.0"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.3"])
  s.add_development_dependency(%q<mocha>.freeze, ["~> 2.1"])
  s.add_development_dependency(%q<yard>.freeze, [">= 0"])
  s.add_development_dependency(%q<i18n>.freeze, [">= 0"])
  s.add_development_dependency(%q<ffaker>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
end
