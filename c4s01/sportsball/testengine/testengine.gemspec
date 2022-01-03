require_relative 'lib/testengine/version'

Gem::Specification.new do |spec|
  spec.name        = 'testengine'
  spec.version     = Testengine::VERSION
  spec.authors     = ['Stephan Hagemann']
  spec.email       = ['stephan.hagemann@gmail.com']
  spec.homepage    = ''
  spec.summary     = 'Summary of Testengine.'
  spec.description = 'Description of Testengine.'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = 'TODO: Set to \'http://mygemserver.com\''

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 7.0.0'
end

