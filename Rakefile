task :default => :spec
task :test    => :spec

desc "Build a gem"
task :gem => [ :gemspec, :build ]

desc "Run specs"
task :spec do
  exec "spec spec/"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "fixed_width"
    gemspec.summary = "A gem that provides a DSL for parsing and writing files of fixed-width records."
    gemspec.description = <<END
Shamelessly forked from ryanwood/slither [http://github.com/ryanwood/slither].

Renamed the gem to be a little clearer as to its purpose. Hate that 'nokogiri' nonsense.
END
    gemspec.email = "timon.karnezos@gmail.com"
    gemspec.homepage = "http://github.com/timonk/fixed_width"
    gemspec.authors = ["Timon Karnezos"]
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