# -*- encoding: utf-8 -*-
# stub: pg 1.1.4 ruby lib
# stub: ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "pg".freeze
  s.version = "1.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze, "Lars Kanis".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIENDCCApygAwIBAgIBATANBgkqhkiG9w0BAQsFADAiMSAwHgYDVQQDDBdnZWQv\nREM9RmFlcmllTVVEL0RDPW9yZzAeFw0xODExMjAxODI5NTlaFw0xOTExMjAxODI5\nNTlaMCIxIDAeBgNVBAMMF2dlZC9EQz1GYWVyaWVNVUQvREM9b3JnMIIBojANBgkq\nhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAvyVhkRzvlEs0fe7145BYLfN6njX9ih5H\nL60U0p0euIurpv84op9CNKF9tx+1WKwyQvQP7qFGuZxkSUuWcP/sFhDXL1lWUuIl\nM4uHbGCRmOshDrF4dgnBeOvkHr1fIhPlJm5FO+Vew8tSQmlDsosxLUx+VB7DrVFO\n5PU2AEbf04GGSrmqADGWXeaslaoRdb1fu/0M5qfPTRn5V39sWD9umuDAF9qqil/x\nSl6phTvgBrG8GExHbNZpLARd3xrBYLEFsX7RvBn2UPfgsrtvpdXjsHGfpT3IPN+B\nvQ66lts4alKC69TE5cuKasWBm+16A4aEe3XdZBRNmtOu/g81gvwA7fkJHKllJuaI\ndXzdHqq+zbGZVSQ7pRYHYomD0IiDe1DbIouFnPWmagaBnGHwXkDT2bKKP+s2v21m\nozilJg4aar2okb/RA6VS87o+d7g6LpDDMMQjH4G9OPnJENLdhu8KnPw/ivSVvQw7\nN2I4L/ZOIe2DIVuYH7aLHfjZDQv/mNgpAgMBAAGjdTBzMAkGA1UdEwQCMAAwCwYD\nVR0PBAQDAgSwMB0GA1UdDgQWBBRyjf55EbrHagiRLqt5YAd3yb8k4DAcBgNVHREE\nFTATgRFnZWRARmFlcmllTVVELm9yZzAcBgNVHRIEFTATgRFnZWRARmFlcmllTVVE\nLm9yZzANBgkqhkiG9w0BAQsFAAOCAYEAP9Ffkvg4e8CjIWi8SykQ8oJSS8jbmbgF\nabke3vXWLG6V9kFiObuJd5wZRBluJANu7bEtjgc3fFaGVP2XxVdCpVjNbmMDg4Qp\novvczP53X6pQP2RSZgxF6Lblvy8y11RziUTVRG/Z2aJHsElo6gI7vQznE/OSDrhC\ngEhr8uaIUt7D+HZWRbU0+MkKPpL5uMqaFuJbqXEvSwPTuUuYkDfNfsjQO7ruWBac\nbxHCrvpZ6Tijc0nrlyXi6gPOCLeaqhau2xFnlvKgELwsGYSoKBJyDwqtQ5kwrOlU\ntkSyLrfZ+RZcH535Hyvif7ZxB0v5OxXXoec+N2vrUsEUMRDL9dg4/WFdN8hIOixF\n3IPKpZ1ho0Ya5q7yhygtBK9/NBFHw+nbJjcltfPDBXleRe8u73gnQo8AZIhStYSP\nv4qqqa27Bs468d6SoPxjSm8a2mM9HZ4OdWhq4tFsbTeXDVquCfi64OTEaTt2xQdR\nJnC4lpJfCP6aCXa5h2XAQfPSH636cQap\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2019-01-09"
  s.description = "Pg is the Ruby interface to the {PostgreSQL RDBMS}[http://www.postgresql.org/].\n\nIt works with {PostgreSQL 9.2 and later}[http://www.postgresql.org/support/versioning/].\n\nA small example usage:\n\n  #!/usr/bin/env ruby\n\n  require 'pg'\n\n  # Output a table of current connections to the DB\n  conn = PG.connect( dbname: 'sales' )\n  conn.exec( \"SELECT * FROM pg_stat_activity\" ) do |result|\n    puts \"     PID | User             | Query\"\n    result.each do |row|\n      puts \" %7d | %-16s | %s \" %\n        row.values_at('procpid', 'usename', 'current_query')\n    end\n  end".freeze
  s.email = ["ged@FaerieMUD.org".freeze, "lars@greiz-reinsdorf.de".freeze]
  s.extensions = ["ext/extconf.rb".freeze]
  s.extra_rdoc_files = ["Contributors.rdoc".freeze, "History.rdoc".freeze, "Manifest.txt".freeze, "README-OS_X.rdoc".freeze, "README-Windows.rdoc".freeze, "README.ja.rdoc".freeze, "README.rdoc".freeze, "ext/errorcodes.txt".freeze, "POSTGRES".freeze, "LICENSE".freeze, "ext/gvl_wrappers.c".freeze, "ext/pg.c".freeze, "ext/pg_binary_decoder.c".freeze, "ext/pg_binary_encoder.c".freeze, "ext/pg_coder.c".freeze, "ext/pg_connection.c".freeze, "ext/pg_copy_coder.c".freeze, "ext/pg_errors.c".freeze, "ext/pg_result.c".freeze, "ext/pg_text_decoder.c".freeze, "ext/pg_text_encoder.c".freeze, "ext/pg_tuple.c".freeze, "ext/pg_type_map.c".freeze, "ext/pg_type_map_all_strings.c".freeze, "ext/pg_type_map_by_class.c".freeze, "ext/pg_type_map_by_column.c".freeze, "ext/pg_type_map_by_mri_type.c".freeze, "ext/pg_type_map_by_oid.c".freeze, "ext/pg_type_map_in_ruby.c".freeze, "ext/util.c".freeze]
  s.files = ["Contributors.rdoc".freeze, "History.rdoc".freeze, "LICENSE".freeze, "Manifest.txt".freeze, "POSTGRES".freeze, "README-OS_X.rdoc".freeze, "README-Windows.rdoc".freeze, "README.ja.rdoc".freeze, "README.rdoc".freeze, "ext/errorcodes.txt".freeze, "ext/extconf.rb".freeze, "ext/gvl_wrappers.c".freeze, "ext/pg.c".freeze, "ext/pg_binary_decoder.c".freeze, "ext/pg_binary_encoder.c".freeze, "ext/pg_coder.c".freeze, "ext/pg_connection.c".freeze, "ext/pg_copy_coder.c".freeze, "ext/pg_errors.c".freeze, "ext/pg_result.c".freeze, "ext/pg_text_decoder.c".freeze, "ext/pg_text_encoder.c".freeze, "ext/pg_tuple.c".freeze, "ext/pg_type_map.c".freeze, "ext/pg_type_map_all_strings.c".freeze, "ext/pg_type_map_by_class.c".freeze, "ext/pg_type_map_by_column.c".freeze, "ext/pg_type_map_by_mri_type.c".freeze, "ext/pg_type_map_by_oid.c".freeze, "ext/pg_type_map_in_ruby.c".freeze, "ext/util.c".freeze]
  s.homepage = "https://bitbucket.org/ged/ruby-pg".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Pg is the Ruby interface to the {PostgreSQL RDBMS}[http://www.postgresql.org/]".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
      s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<rake-compiler-dock>.freeze, ["~> 0.7.0"])
      s.add_development_dependency(%q<hoe-bundler>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 5.1"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.16"])
    else
      s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
      s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_dependency(%q<rake-compiler>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rake-compiler-dock>.freeze, ["~> 0.7.0"])
      s.add_dependency(%q<hoe-bundler>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 5.1"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
    end
  else
    s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
    s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
    s.add_dependency(%q<rake-compiler>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rake-compiler-dock>.freeze, ["~> 0.7.0"])
    s.add_dependency(%q<hoe-bundler>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 5.1"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
  end
end
