# -*- encoding: utf-8 -*-
# stub: visualize_packwerk 0.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "visualize_packwerk".freeze
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "changelog_uri" => "https://github.com/rubyatscale/visualize_packwerk/releases", "homepage_uri" => "https://github.com/rubyatscale/visualize_packwerk", "source_code_uri" => "https://github.com/rubyatscale/visualize_packwerk" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Gusto Engineers".freeze]
  s.date = "2023-07-11"
  s.description = "A gem to visualize connections in a Rails app that uses Packwerk".freeze
  s.email = ["dev@gusto.com".freeze]
  s.executables = ["visualize_packs".freeze]
  s.files = ["README.md".freeze, "bin/visualize_packs".freeze, "lib/graph.dot.erb".freeze, "lib/visualize_packwerk.rb".freeze]
  s.homepage = "https://github.com/rubyatscale/visualize_packwerk".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.4.1".freeze
  s.summary = "A gem to visualize connections in a Rails app that uses Packwerk".freeze

  s.installed_by_version = "3.4.1" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<packs>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<parse_packwerk>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.2.16"])
end
