# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fixed_width_multirecord"
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jason Yanowitz", "Timon Karnezos", "Ryan Wood"]
  s.date = "2012-07-11"
  s.description = "A gem that provides a DSL for parsing and writing files of fixed-width records.\n\nShamelessly forked from ryanwood/slither [http://github.com/ryanwood/slither].\n\nRenamed the gem to be a little clearer as to its purpose. Hate that 'nokogiri' nonsense.\n\nReshamelessly forked from Timon's version to add multi-line record support\n"
  s.email = "jyanowitz@groupon.com"
  s.extra_rdoc_files = [
    "README.markdown",
    "TODO"
  ]
  s.files = [
    "COPYING",
    "HISTORY",
    "README.markdown",
    "Rakefile",
    "TODO",
    "VERSION",
    "examples/readme_example.rb",
    "fixed_width_multirecord.gemspec",
    "lib/fixed_width_multirecord.rb",
    "lib/fixed_width_multirecord/column.rb",
    "lib/fixed_width_multirecord/core_ext/symbol.rb",
    "lib/fixed_width_multirecord/definition.rb",
    "lib/fixed_width_multirecord/fixed_width_multirecord.rb",
    "lib/fixed_width_multirecord/generator.rb",
    "lib/fixed_width_multirecord/line_parser.rb",
    "lib/fixed_width_multirecord/parser.rb",
    "lib/fixed_width_multirecord/section.rb",
    "spec/column_spec.rb",
    "spec/definition_spec.rb",
    "spec/fixed_width_multirecord_spec.rb",
    "spec/generator_spec.rb",
    "spec/line_parser_spec.rb",
    "spec/parser_spec.rb",
    "spec/section_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/yanowitz/fixed_width_multirecord"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.21"
  s.summary = "A gem that provides a DSL for parsing and writing files of fixed-width records."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

