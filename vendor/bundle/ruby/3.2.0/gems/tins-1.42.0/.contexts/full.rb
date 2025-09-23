context do
  variable project_name: Pathname.pwd.basename

  variable project_version: File.read('VERSION').chomp

  variable branch: `git rev-parse --abbrev-ref HEAD`.chomp

  namespace "structure" do
    command "tree", tags: %w[ project_structure ]
  end

  namespace "lib" do
    Dir['lib/**/*.rb'].each do |filename|
      file filename, tags: 'lib'
    end
  end

  namespace "tests" do
    Dir['tests/**/*.rb'].each do |filename|
      file filename, tags: 'test'
    end
  end

  file 'Rakefile',  tags: 'gem_hadar'

  file 'README.md', tags: 'documentation'

  meta ruby: RUBY_DESCRIPTION

  meta code_coverage: json('coverage/coverage_context.json')
end
