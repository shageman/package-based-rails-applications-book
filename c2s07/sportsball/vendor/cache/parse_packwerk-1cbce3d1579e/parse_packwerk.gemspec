# -*- encoding: utf-8 -*-
# stub: parse_packwerk 0.19.3 ruby lib

Gem::Specification.new do |s|
  s.name = "parse_packwerk".freeze
  s.version = "0.19.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "changelog_uri" => "https://github.com/rubyatscale/parse_packwerk/releases", "homepage_uri" => "https://github.com/rubyatscale/parse_packwerk", "source_code_uri" => "https://github.com/rubyatscale/parse_packwerk" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Gusto Engineers".freeze]
  s.date = "2023-07-17"
  s.description = "A low-dependency gem for parsing and writing packwerk YML files".freeze
  s.email = ["dev@gusto.com".freeze]
  s.files = ["README.md".freeze, "lib/parse_packwerk".freeze, "lib/parse_packwerk.rb".freeze, "lib/parse_packwerk/configuration.rb".freeze, "lib/parse_packwerk/constants.rb".freeze, "lib/parse_packwerk/extensions.rb".freeze, "lib/parse_packwerk/package.rb".freeze, "lib/parse_packwerk/package_set.rb".freeze, "lib/parse_packwerk/package_todo.rb".freeze, "lib/parse_packwerk/violation.rb".freeze]
  s.homepage = "https://github.com/rubyatscale/parse_packwerk".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.4.1".freeze
  s.summary = "A low-dependency gem for parsing and writing packwerk YML files".freeze

  s.installed_by_version = "3.4.1" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<sorbet-runtime>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.2.16"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<sorbet>.freeze, [">= 0"])
  s.add_development_dependency(%q<tapioca>.freeze, [">= 0"])
  s.add_development_dependency(%q<hashdiff>.freeze, [">= 0"])
  s.add_development_dependency(%q<awesome_print>.freeze, [">= 0"])
end
