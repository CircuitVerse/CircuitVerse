if Rails::VERSION::MAJOR < 4
  DummyApp::Application.config.secret_token = 'f2338e8b8018053b0b322cd6469d8c0ed06ab0aaf43dd30a1c33a4c55d9c0d6a1c1ad4140049019f85388db3ce1ddbeff597cf07c49c5b22242cecd146f2bd66'
end
