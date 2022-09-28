namespace :javascript do
  namespace :install do
    desc "Install shared elements for all bundlers"
    task :shared do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/install.rb",  __dir__)}"
    end

    desc "Install esbuild"
    task esbuild: "javascript:install:shared" do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/esbuild/install.rb",  __dir__)}"
    end

    desc "Install rollup.js"
    task rollup: "javascript:install:shared" do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/rollup/install.rb",  __dir__)}"
    end

    desc "Install Webpack"
    task webpack: "javascript:install:shared" do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/webpack/install.rb",  __dir__)}"
    end
  end
end
