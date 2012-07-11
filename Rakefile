task :default => :spec
task :test    => :spec

desc "Build a gem"
task :gem => [ :gemspec, :build ]

desc "Run specs"
task :spec do
  exec "spec -fn -b -c spec/"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "fixed_width_multirecord"
    gemspec.summary = "A gem that provides a DSL for parsing and writing files of fixed-width records."
    gemspec.description = <<END
A gem that provides a DSL for parsing and writing files of fixed-width records.

Shamelessly forked from ryanwood/slither [http://github.com/ryanwood/slither].

Renamed the gem to be a little clearer as to its purpose. Hate that 'nokogiri' nonsense.

Reshamelessly forked from Timon's version to add multi-line record support
END
    gemspec.email = "jyanowitz@groupon.com"
    gemspec.homepage = "http://github.com/yanowitz/fixed_width_multirecord"
    gemspec.authors = ["Jason Yanowitz", "Timon Karnezos", "Ryan Wood"]
  end
rescue LoadError
  warn "Jeweler not available. Install it with:"
  warn "gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rprince #{version}"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
