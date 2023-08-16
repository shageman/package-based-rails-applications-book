# -*- encoding: utf-8 -*-
# stub: parse_packwerk 0.19.3 ruby lib

Gem::Specification.new do |s|
  s.name        = 'prediction_component'
  s.version     = '0.1.0'
  s.summary     = "This is an example!"
  s.authors     = ["Ruby Coder"]
  s.files       = ["lib/**/*"]

  s.add_dependency 'eventide-postgres'
  s.add_dependency 'evt-try'
  s.add_dependency 'evt-component_host'
  s.add_dependency 'trueskill'
end