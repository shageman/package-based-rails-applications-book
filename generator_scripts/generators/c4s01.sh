#!/bin/bash

set -v
set -x
set -e

bundle install --local

rails plugin new testengine \
  --full \
  --mountable

rm -rf testengine/.git
rm -rf testengine/.gitignore

echo "require_relative 'lib/testengine/version'

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

  spec.add_dependency 'rails', '~> 6.1.3', '>= 6.1.3.2'
end
" > testengine/testengine.gemspec

echo '
enforce_dependencies: true
enforce_privacy: false
' > testengine/package.yml

# Change to directories known to packwerk:

sed -i "/packages.welcome_ui.app.views/a - testengine/app/models" packwerk.yml
sed -i "/packages.welcome_ui.app.views/a - testengine/app/mailers" packwerk.yml
sed -i "/packages.welcome_ui.app.views/a - testengine/app/jobs" packwerk.yml
sed -i "/packages.welcome_ui.app.views/a - testengine/app/helpers" packwerk.yml
sed -i "/packages.welcome_ui.app.views/a - testengine/app/controllers" packwerk.yml
