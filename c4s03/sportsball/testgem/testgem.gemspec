# frozen_string_literal: true

require_relative 'lib/testgem/version'

Gem::Specification.new do |spec|
  spec.name          = 'testgem'
  spec.version       = Testgem::VERSION
  spec.authors       = ['Stephan Hagemann']
  spec.email         = ['stephan.hagemann@gmail.com']

  spec.summary       = 'Write a short summary, because RubyGems requires one.'
  spec.description   = 'Write a longer description or delete this line.'
  spec.required_ruby_version = '>= 2.4.0'

  spec.metadata['allowed_push_host'] = 'Set to http://mygemserver.com'

  spec.files = Dir['app/**/*.rb', 'lib/**/*.rb'] + Dir['bin/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'zeitwerk'
end
