# encoding: utf-8

require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

task :default => :spec

desc "Generate a random po file to \"test/benchmark.po\". Takes optional rake args for number of entries"
task 'generate_random_pofile', :messages, :obsoletes do |t, args|
  args.with_defaults(:messages => "200", :obsoletes => "10")
  require_relative 'spec/utils/random_pofile_generator'
  PoParser::RandomPoFileGenerator.generate_file(
    File.expand_path("test/benchmark.po", __dir__), args[:messages].to_i, args[:obsoletes].to_i
  )
end

namespace :parser do
  require 'benchmark'
  require 'simple_po_parser'

  desc "Benchmark of 1000 full PoParser runs of test/benchmark.po"
  task "benchmark" do
    pofile = File.expand_path("test/benchmark.po", __dir__)
    Benchmark.bmbm do |x|
      x.report("Parser:") {1000.times { SimplePoParser.parse(pofile) }}
    end
  end

  desc "Generate 5 random PO files with 1000 to 5000 messages and benchmark each full PoParser run"
  task 'five_random_po_full' do
    include Benchmark
    require_relative 'spec/utils/random_pofile_generator'
    pofile = File.expand_path("test/benchmark.po.tmp", __dir__)
    Benchmark.benchmark(CAPTION, 6, FORMAT, "total:") do |x|
      total = nil
      total_length = 0
      for i in 0..5 do
        length = (Random.new.rand * 4000.0 + 1000).to_i
        total_length += length
        puts "Benchmarking file of length #{length}"
        SimplePoParser::RandomPoFileGenerator.generate_file(pofile, length)
        t = x.report("try#{i}:") {SimplePoParser.parse(pofile)}
        File.unlink(pofile)
        total = total ? total+t : t
      end
      puts "Total message length #{total_length}"
      [total]
    end
  end

  desc "Show ruby-prof profiler for spec/fixtures/complex_entry.po"
  task "profile_parser" do
    require 'ruby-prof'
    po_message = File.read(File.expand_path("spec/simple_po_parser/fixtures/complex_entry.po", __dir__))
    RubyProf.start
    SimplePoParser.parse_message(po_message)
    result = RubyProf.stop

    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT)
  end
end
